class_name VoxelEngineChunkManager extends Node3D

## Configuration for chunk generation and rendering
@export var use_hexagons: bool = false
@export var use_collision: bool = false
@export var context_target: Node3D
@export var chunk_size: int = 64
@export var noise_seed: int = 0
@export var generation_height: int = 16
@export var generation_radius: int = 5
@export var render_radius: int = 5
@export var colors: Array[Color] = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW]
@export var highlight_shader_material: ShaderMaterial

@onready var highlight_mesh_instance: MeshInstance3D = $Highlight

## Internal management variables
var noise: FastNoiseLite = FastNoiseLite.new()
var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var active_chunks: Dictionary[Vector3i, Dictionary] = {}
var current_player_chunk: Vector3i = Vector3i.ZERO
var data_initialized: bool = false
var logic_class: Object = VoxelEngineVoxel
var rid_to_coordinate: Dictionary[RID, Vector3i] = {}
var hovered_chunk: Vector3i
var hovered_voxel: Vector3i
var hovered_normal: Vector3
var last_hit_rid: RID

# ===
# Built-In
# ===

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = noise_seed
	logic_class = VoxelEngineHexagon if use_hexagons else VoxelEngineCube
	
	# Hover
	if highlight_shader_material:
		var mat := highlight_shader_material.duplicate()
		highlight_mesh_instance.material_override = mat
	
	generate_world_data()
	_update_highlight_mesh_type()

func _process(_delta: float) -> void:
	if not data_initialized or not context_target:
		return
	
	var new_chunk_coordinate: Vector3i = logic_class.world_to_chunk(context_target.global_position, chunk_size)
	if new_chunk_coordinate != current_player_chunk:
		current_player_chunk = new_chunk_coordinate
		update_render_distance()

# ===
# Public
# ===

func generate_world_data() -> void:
	var y_max: int = int(ceil(generation_height / float(chunk_size)))
	for x: int in range(-generation_radius, generation_radius + 1):
		for z: int in range(-generation_radius, generation_radius + 1):
			if Vector2(x, z).length() <= generation_radius:
				for y: int in range(0, y_max):
					var coordinate: Vector3i = Vector3i(x, y, z)
					chunks_data[coordinate] = generate_raw_voxels(get_chunk_position(coordinate))
	print_debug(chunks_data.keys())
	data_initialized = true
	update_render_distance()

func generate_raw_voxels(origin: Vector3) -> PackedByteArray:
	var voxels: PackedByteArray = PackedByteArray()
	voxels.resize(chunk_size**3)
	voxels.fill(0)
	
	for x: int in range(chunk_size):
		for z: int in range(chunk_size):
			# Pass the actual world origin of the chunk
			var sample: Vector2 = logic_class.get_noise_coords(x, z, origin)
			var height: float = (noise.get_noise_2d(sample.x, sample.y) + 1.0) / 2.0 * generation_height
			
			for y: int in range(min(int(max(0.0, height - origin.y)), chunk_size)):
				voxels[x + (y * chunk_size) + (z * chunk_size**2)] = (y % colors.size()) + 1
	return voxels

func update_render_distance() -> void:
	var needed_coordinates: Array[Vector3i] = []
	for x: int in range(-render_radius, render_radius + 1):
		for z: int in range(-render_radius, render_radius + 1):
			if Vector2(x, z).length() <= render_radius:
				needed_coordinates.append(current_player_chunk + Vector3i(x, 0, z))
	
	for coordinate: Vector3i in needed_coordinates:
		if not active_chunks.has(coordinate) and chunks_data.has(coordinate):
			_spawn_chunk(coordinate)
			
	for coordinate: Vector3i in active_chunks.keys().duplicate():
		if not coordinate in needed_coordinates:
			_remove_chunk(coordinate)

func get_chunk_position(coordinate: Vector3i) -> Vector3:
	if not use_hexagons:
		return Vector3(coordinate * chunk_size)
		
	var s := float(chunk_size)
	# The chunk offset must be an integer multiple of the voxel spacing
	# Use the same logic as _get_hex_world_pos but for the chunk root
	return Vector3(
		s * 1.5 * coordinate.x,
		0,
		s * sqrt(3.0) * (coordinate.z + 0.5 * coordinate.x)
	)

func get_voxel_data(coord: Vector3i, local_voxel: Vector3i) -> int:
	var data = chunks_data.get(coord)
	if not data: return 0
	return data[logic_class.get_index(local_voxel.x, local_voxel.y, local_voxel.z, chunk_size)]

func request_voxel_geometry(coord: Vector3i, local_voxel: Vector3i) -> Dictionary:
	var data = chunks_data.get(coord)
	if not data: return {}
	return logic_class.get_single_voxel_geometry(
		local_voxel, data, coord, chunks_data, chunk_size, Color.WHITE
	)

func remove_voxel(chunk_coord: Vector3i, local_voxel: Vector3i) -> void:
	var data = chunks_data.get(chunk_coord)
	if not data: return
	
	# Update Logical Data
	var idx = logic_class.get_index(local_voxel.x, local_voxel.y, local_voxel.z, chunk_size)
	data[idx] = 0
	
	_process_mesh(chunk_coord, data)

# ===
# Private
# ===

func _update_highlight_mesh_type() -> void:
	highlight_mesh_instance.mesh = null
	highlight_mesh_instance.rotation_degrees = Vector3.ZERO
	
	if use_hexagons:
		var hex_mesh := CylinderMesh.new()
		hex_mesh.radial_segments = 6
		hex_mesh.cap_top = true
		hex_mesh.cap_bottom = true
		hex_mesh.top_radius = 1.0
		hex_mesh.bottom_radius = 1.0
		hex_mesh.height = 1.0
		
		highlight_mesh_instance.mesh = hex_mesh
		# Rotate 30 degrees (PI/6 radians) on the Y axis to align the flat sides
		highlight_mesh_instance.rotation_degrees = Vector3(0, 30, 0)
	else:
		highlight_mesh_instance.mesh = BoxMesh.new()
		highlight_mesh_instance.mesh.size = Vector3.ONE
		highlight_mesh_instance.rotation_degrees = Vector3.ZERO

func _update_highlight_material() -> void:
	if highlight_shader_material and highlight_mesh_instance:
		highlight_mesh_instance.material_override = highlight_shader_material

func _spawn_chunk(coordinate: Vector3i) -> void:
	var mesh_rid: RID = RenderingServer.mesh_create()
	var instance_rid: RID = RenderingServer.instance_create()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	
	material.vertex_color_use_as_albedo = true
	
	RenderingServer.instance_set_base(
		instance_rid, 
		mesh_rid
	)
	RenderingServer.instance_geometry_set_material_override(
		instance_rid, 
		material.get_rid()
	)
	RenderingServer.instance_set_scenario(
		instance_rid, 
		get_world_3d().scenario
	)
	RenderingServer.instance_set_transform(
		instance_rid,
		Transform3D(Basis(), 
		logic_class.chunk_to_world(coordinate, chunk_size))
	)

	active_chunks[coordinate] = {
		"mesh": mesh_rid,
		"instance": instance_rid,
		"material": material,
		"body": RID(),
		"shape": RID()
	}
	
	WorkerThreadPool.add_task(
		func() -> void: 
			_process_mesh(coordinate, chunks_data[coordinate])
	)

func _process_mesh(coord: Vector3i, data: PackedByteArray) -> void:
	var geometry: Dictionary = logic_class.calculate_geometry(
		data,
		coord,
		chunks_data,
		chunk_size,
		colors
	)

	call_deferred("_apply_result", coord, geometry)

func _apply_result(coordinate: Vector3i, geometry: Dictionary) -> void:
	if not active_chunks.has(coordinate):
		return
		
	var chunk: Dictionary = active_chunks[coordinate]
	
	# 1. Update Rendering
	var surface_array: Array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = geometry.verts
	surface_array[Mesh.ARRAY_NORMAL] = geometry.norms
	surface_array[Mesh.ARRAY_COLOR] = geometry.cols
	surface_array[Mesh.ARRAY_TEX_UV] = geometry.uvs
	
	RenderingServer.mesh_clear(chunk.mesh)
	if not geometry.verts.is_empty():
		RenderingServer.mesh_add_surface_from_arrays(chunk.mesh, RenderingServer.PRIMITIVE_TRIANGLES, surface_array)
	
	# Update Physics
	if chunk.body.is_valid():
		rid_to_coordinate.erase(chunk.body)
		PhysicsServer3D.free_rid(chunk.body)
		chunk.body = RID()

	if not geometry.verts.is_empty():
		chunk.body = PhysicsServer3D.body_create()
		PhysicsServer3D.body_set_mode(chunk.body, PhysicsServer3D.BODY_MODE_STATIC)
		PhysicsServer3D.body_set_space(chunk.body, get_world_3d().space)
		
		# Ensure the body is on a collision layer (e.g., layer 1)
		PhysicsServer3D.body_set_collision_layer(chunk.body, 1)
		PhysicsServer3D.body_set_collision_mask(chunk.body, 1)

		var shape := PhysicsServer3D.concave_polygon_shape_create()
		PhysicsServer3D.shape_set_data(shape, {"faces": geometry.verts, "backface_collision": false})
		
		print(get_chunk_position(coordinate))
		PhysicsServer3D.body_add_shape(chunk.body, shape)
		PhysicsServer3D.body_set_state(
			chunk.body,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), get_chunk_position(coordinate))
		)
		
		rid_to_coordinate[chunk.body] = coordinate
		chunk.shape = shape

func _remove_chunk(coord: Vector3i) -> void:
	var chunk := active_chunks[coord]

	RenderingServer.free_rid(chunk.instance)
	RenderingServer.free_rid(chunk.mesh)

	if chunk.body.is_valid():
		PhysicsServer3D.free_rid(chunk.body)

	if chunk.shape.is_valid():
		PhysicsServer3D.free_rid(chunk.shape)

	rid_to_coordinate.erase(chunk.body)
	active_chunks.erase(coord)
