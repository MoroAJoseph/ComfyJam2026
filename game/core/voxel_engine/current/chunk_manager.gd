class_name VoxelEngineChunkManager extends Node3D

signal block_removed(block_type: Enums.BlockType,global_pos: Vector3i)

@export_group("Generation Settings")
@export var use_hexagons: bool = false
@export var use_collision: bool = false
@export var chunk_size: int = 64
@export var generation_height: int = 16
@export var generation_radius: int = 5
@export var render_radius: int = 5

@export_group("Terran Settings")
@export var noise: FastNoiseLite
@export var noise_seed: int = 0
@export var colors: Array[Color] = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW]
@export var sea_level: int = 8

@export_group("Configs")
@export var highlight_shader_material: ShaderMaterial
@export var voxel_shader_material: ShaderMaterial
@export var context_target: Node3D

@onready var highlight_mesh_instance: MeshInstance3D = $Highlight
@onready var logic_class: Object = VoxelEngineHexagon if use_hexagons else VoxelEngineCube

## Internal management variables
var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var active_chunks: Dictionary[Vector3i, Dictionary] = {}
var dirty_chunks: Dictionary[Vector3i, bool] = {}
var loading_chunks: Array[Vector3i] = []
var current_player_chunk: Vector3i = Vector3i.ZERO
var data_initialized: bool = false
var rid_to_coordinate: Dictionary[RID, Vector3i] = {}
var hovered_chunk: Vector3i
var hovered_voxel: Vector3i
var hovered_normal: Vector3
var last_hit_rid: RID
var total_voxels: int
var tracking_enabled: bool = false

# ===
# Built-In
# ===

func _ready() -> void:
	# Hover
	if highlight_shader_material:
		var mat := highlight_shader_material.duplicate()
		highlight_mesh_instance.material_override = mat

func _process(_delta: float) -> void:
	# Only track and render if we have a target AND have finished generation
	if not (
		data_initialized and 
		context_target and 
		tracking_enabled
	):
		return
	
	var new_chunk_coordinate: Vector3i = logic_class.world_to_chunk(
		context_target.global_position, 
		chunk_size
	)
	
	if new_chunk_coordinate != current_player_chunk:
		current_player_chunk = new_chunk_coordinate
		update_render_distance()
	
	# Process one dirty chunk per frame (as existing)
	if not dirty_chunks.is_empty():
		var coord = dirty_chunks.keys()[0]
		_process_mesh(coord, chunks_data[coord])

# ===
# Public
# ===

func generate_data() -> void:
	noise.seed = noise_seed
	var start_time: int = Time.get_ticks_msec()
	generate_world_data()
	
	var end_time: int = Time.get_ticks_msec()
	var duration_seconds: float = (end_time - start_time) / 1000.0
	
	var total = get_total_voxel_count()
	print_debug("Generation complete in %.3f seconds." % duration_seconds)
	print_debug("Total voxels in generated world data: %d" % total)
	_update_highlight_mesh_type()

func start_tracking(target: Node3D) -> void:
	context_target = target
	tracking_enabled = true
	update_render_distance()

func get_total_voxel_count() -> int:
	var total: int = 0
	for data: PackedByteArray in chunks_data.values():
		for b: int in data:
			if b > 0:
				total += 1
	return total

func get_generation_settings(world_pos: Vector3) -> Dictionary:
	var dist = Vector2(world_pos.x, world_pos.z).length()
	var zone = int(dist / 500.0)
	
	# Example: Increase height and noise influence as zone increases
	var max_height = 10 + (zone * 5)
	var density_threshold = 0.5 - (zone * 0.05) # Gets denser/easier to find land
	
	return {"max_height": max_height, "threshold": max(0.1, density_threshold)}

func generate_world_data() -> void:
	var y_max: int = int(ceil(generation_height / float(chunk_size)))
	for x: int in range(-generation_radius, generation_radius + 1):
		for z: int in range(-generation_radius, generation_radius + 1):
			if Vector2(x, z).length() <= generation_radius:
				for y: int in range(0, y_max):
					var coordinate: Vector3i = Vector3i(x, y, z)
					chunks_data[coordinate] = generate_raw_voxels(
						logic_class.chunk_to_world(coordinate, chunk_size)
					)
	data_initialized = true
	update_render_distance()

func generate_raw_voxels(origin: Vector3) -> PackedByteArray:
	var voxels := PackedByteArray()
	voxels.resize(chunk_size * chunk_size * chunk_size)
	voxels.fill(0) # 0 is Air/Empty

	for x in range(chunk_size):
		for z in range(chunk_size):
			for y in range(chunk_size):
				var world_pos = origin + logic_class.voxel_to_world(
					Vector3i(x, y, z), Vector3.ZERO
				)

				var density := noise.get_noise_3d(world_pos.x, world_pos.y, world_pos.z)
				var height_gradient = world_pos.y / float(generation_height)
				var final_density = density - height_gradient

				if final_density > 0.0 and world_pos.y >= sea_level:
					# Default to COBBLESTONE
					var block_type: Enums.BlockType = Enums.BlockType.COBBLESTONE

					if world_pos.y < sea_level + 2:
						block_type = Enums.BlockType.STONE
					elif world_pos.y < sea_level + 5:
						block_type = Enums.BlockType.MOSSY_COBBLESTONE

					# Store the Enum value (casted to int)
					voxels[
						x + (y * chunk_size) + (z * chunk_size * chunk_size)
					] = int(block_type)

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

func remove_voxel(chunk_coord: Vector3i, local_voxel: Vector3i) -> void:
	var data = chunks_data.get(chunk_coord)
	if not data: return
	
	var idx = logic_class.get_index(local_voxel.x, local_voxel.y, local_voxel.z, chunk_size)
	
	var block_type: Enums.BlockType = data[idx] as Enums.BlockType
	
	var chunk_origin = logic_class.chunk_to_world(chunk_coord, chunk_size)
	var global_pos = logic_class.voxel_to_world(local_voxel, chunk_origin)
	
	data[idx] = 0
	
	block_removed.emit(block_type, global_pos)
	
	_process_mesh(chunk_coord, data)

## Updates the highlight mesh visual state
func update_hover_visuals(chunk_coord: Vector3i, local_voxel: Vector3i) -> void:
	# Position
	var chunk_origin = logic_class.chunk_to_world(chunk_coord, chunk_size)
	var voxel_world_pos = logic_class.voxel_to_world(local_voxel, chunk_origin)
	highlight_mesh_instance.global_position = voxel_world_pos
	highlight_mesh_instance.visible = true

## Hides the visual highlight
func hide_hover_visuals() -> void:
	highlight_mesh_instance.visible = false

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
	else:
		highlight_mesh_instance.mesh = BoxMesh.new()
		highlight_mesh_instance.mesh.size = Vector3.ONE
		highlight_mesh_instance.rotation_degrees = Vector3.ZERO

func _update_highlight_material() -> void:
	if highlight_shader_material and highlight_mesh_instance:
		highlight_mesh_instance.material_override = highlight_shader_material

func _spawn_chunk(coordinate: Vector3i) -> void:
	if loading_chunks.has(coordinate): return
		
	loading_chunks.append(coordinate)
	
	var mesh_rid: RID = RenderingServer.mesh_create()
	var instance_rid: RID = RenderingServer.instance_create()
	
	
	RenderingServer.instance_set_base(
		instance_rid, 
		mesh_rid
	)
	RenderingServer.instance_geometry_set_material_override(
		instance_rid, 
		voxel_shader_material.get_rid()
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
		"material": voxel_shader_material,
		"body": RID(),
		"shape": RID()
	}
	
	WorkerThreadPool.add_task(
		func() -> void: 
			_process_mesh(coordinate, chunks_data[coordinate])
	)

func _process_mesh(coord: Vector3i, data: PackedByteArray) -> void:
	var geometry: Dictionary
	
	if use_hexagons:
		geometry = logic_class.calculate_textured_geometry(
			data,
			coord,
			chunks_data,
			chunk_size,
		)
	else:
		geometry = logic_class.calculate_geometry(
			data,
			coord,
			chunks_data,
			chunk_size,
			colors
		)

	call_deferred("_apply_result", coord, geometry)

func _apply_result(coordinate: Vector3i, geometry: Dictionary) -> void:
	loading_chunks.erase(coordinate)
	if not active_chunks.has(coordinate): return
	
	var chunk: Dictionary = active_chunks[coordinate]
	RenderingServer.mesh_clear(chunk.mesh)
	
	var vertices: PackedVector3Array = geometry.vertices
	if not vertices.is_empty():
		var vertex_count: int = vertices.size()
		
		# Validate Tangents
		if geometry.has("tangents") and (geometry.tangents.size() / 4 != vertex_count):
			push_error("Tangent array size mismatch! Expected: %d, Got: %d" % [vertex_count * 4, geometry.tangents.size()])
			return
		
		# Build Surface Arrays
		var surface_array: Array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		
		surface_array[Mesh.ARRAY_VERTEX]  = vertices
		surface_array[Mesh.ARRAY_NORMAL]  = geometry.normals as PackedVector3Array
		surface_array[Mesh.ARRAY_TANGENT] = geometry.tangents as PackedFloat32Array
		surface_array[Mesh.ARRAY_TEX_UV]  = geometry.uvs as PackedVector2Array
		
		# FIX: Only set COLOR if it exists and matches the vertex count
		if geometry.has("colors") and (geometry.colors as PackedColorArray).size() == vertex_count:
			surface_array[Mesh.ARRAY_COLOR] = geometry.colors
		else:
			surface_array[Mesh.ARRAY_COLOR] = null
		
		RenderingServer.mesh_add_surface_from_arrays(
			chunk.mesh, 
			RenderingServer.PRIMITIVE_TRIANGLES, 
			surface_array
		)
	
	# Update Physics
	if not use_collision: return
	
	if chunk.body.is_valid():
		rid_to_coordinate.erase(chunk.body)
		PhysicsServer3D.free_rid(chunk.body)
		chunk.body = RID()
	
	if not geometry.vertices.is_empty():
		chunk.body = PhysicsServer3D.body_create()
		PhysicsServer3D.body_set_mode(chunk.body, PhysicsServer3D.BODY_MODE_STATIC)
		PhysicsServer3D.body_set_space(chunk.body, get_world_3d().space)
		
		# Ensure the body is on a collision layer (e.g., layer 1)
		PhysicsServer3D.body_set_collision_layer(chunk.body, 1)
		PhysicsServer3D.body_set_collision_mask(chunk.body, 1)

		var shape := PhysicsServer3D.concave_polygon_shape_create()
		PhysicsServer3D.shape_set_data(shape, {"faces": geometry.vertices, "backface_collision": false})
		
		PhysicsServer3D.body_add_shape(chunk.body, shape)
		PhysicsServer3D.body_set_state(
			chunk.body,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(Basis(), logic_class.chunk_to_world(coordinate, chunk_size))
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
	
