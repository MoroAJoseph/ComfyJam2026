class_name VoxelCSChunkManager 
extends Node3D

@export_group("Generation Settings")
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

var generator: VoxelEngineWorldGenerator = VoxelEngineWorldGenerator.new()
var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var active_chunks: Dictionary[Vector3i, Dictionary] = {}
var loading_chunks: Array[Vector3i] = []
var current_player_chunk: Vector3i = Vector3i.ZERO
var data_initialized: bool = false
var tracking_enabled: bool = false
var hovered_chunk: Vector3i
var hovered_voxel: Vector3i
var hovered_normal: Vector3
var rid_to_coordinate: Dictionary[RID, Vector3i] = {}
var last_hit_rid: RID

# === Lifecycle ===

func _ready() -> void:
	if highlight_shader_material:
		highlight_mesh_instance.material_override = highlight_shader_material.duplicate()

func _exit_tree() -> void:
	for coord in active_chunks.keys():
		_remove_chunk(coord)

func _process(_delta: float) -> void:
	if not (data_initialized and tracking_enabled and context_target): return
	
	var new_coord = VoxelEngineHexagon.world_to_chunk(context_target.global_position, chunk_size)
	if new_coord != current_player_chunk:
		current_player_chunk = new_coord
		update_render_distance()

# === Public API ===

func generate_data() -> void:
	var start_time := Time.get_ticks_msec()
	
	generator.ChunkSize = chunk_size
	generator.GenerationHeight = generation_height
	generator.GenerationRadius = generation_radius
	generator.Noise = noise
	
	generator.GenerateWorldData()
	chunks_data = generator.GetChunksData()
	
	data_initialized = true
	print_debug("Generation complete in %.3fs. Total voxels: %d" % [
		(Time.get_ticks_msec() - start_time) / 1000.0, 
		get_total_voxel_count()
	])
	_update_highlight_mesh()
	update_render_distance()

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

func remove_voxel(chunk_coord: Vector3i, local_voxel: Vector3i) -> void:
	var data = chunks_data.get(chunk_coord)
	if not data: return
	
	var idx = VoxelEngineHexagon.get_index(local_voxel.x, local_voxel.y, local_voxel.z, chunk_size)
	data[idx] = 0
	
	_process_mesh_async(chunk_coord, data)
	
	var neighbors = _get_neighbors_to_update(local_voxel)
	for neighbor_offset in neighbors:
		var neighbor_coord = chunk_coord + neighbor_offset
		if chunks_data.has(neighbor_coord) and active_chunks.has(neighbor_coord):
			_process_mesh_async(neighbor_coord, chunks_data[neighbor_coord])

# === Chunk Management ===

func _spawn_chunk(coord: Vector3i) -> void:
	if loading_chunks.has(coord) or active_chunks.has(coord): return
	loading_chunks.append(coord)
	
	var mesh_rid := RenderingServer.mesh_create()
	var instance_rid := RenderingServer.instance_create()
	
	RenderingServer.instance_set_base(instance_rid, mesh_rid)
	RenderingServer.instance_set_scenario(instance_rid, get_world_3d().scenario)
	RenderingServer.instance_geometry_set_material_override(instance_rid, voxel_shader_material.get_rid())
	RenderingServer.instance_set_transform(instance_rid, Transform3D(Basis(), VoxelEngineHexagon.chunk_to_world(coord, chunk_size)))

	active_chunks[coord] = { "mesh": mesh_rid, "instance": instance_rid, "body": RID(), "shape": RID() }
	WorkerThreadPool.add_task(func(): _generate_mesh_async(coord, chunks_data[coord]))

func _generate_mesh_async(coord: Vector3i, data: PackedByteArray) -> void:
	if not is_inside_tree(): return
	
	var chunks_snapshot = chunks_data.duplicate() 
	
	var geometry = VoxelEngineHexagon.calculate_textured_geometry(data, coord, chunks_snapshot, chunk_size)
	
	if not is_inside_tree(): return
	call_deferred("_apply_result", coord, geometry)

func _process_mesh_async(coord: Vector3i, data: PackedByteArray) -> void:
	WorkerThreadPool.add_task(func(): _generate_mesh_async(coord, data))

func _remove_chunk(coord: Vector3i) -> void:
	if not active_chunks.has(coord): return
	var chunk = active_chunks[coord]
	RenderingServer.free_rid(chunk.instance)
	RenderingServer.free_rid(chunk.mesh)
	if chunk.body.is_valid(): PhysicsServer3D.free_rid(chunk.body)
	if chunk.shape.is_valid(): PhysicsServer3D.free_rid(chunk.shape)
	active_chunks.erase(coord)

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

# === Geometry & Physics ===

func _apply_result(coord: Vector3i, geometry: Dictionary) -> void:
	loading_chunks.erase(coord)
	if not active_chunks.has(coord): return
	
	_update_mesh_surface(active_chunks[coord].mesh, geometry)
	if use_collision: _update_collision(coord, geometry)

func _update_mesh_surface(mesh_rid: RID, geom: Dictionary) -> void:
	RenderingServer.mesh_clear(mesh_rid)
	if geom.vertices.is_empty(): return
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = geom.vertices
	arrays[Mesh.ARRAY_NORMAL] = geom.normals
	arrays[Mesh.ARRAY_TANGENT] = geom.tangents
	arrays[Mesh.ARRAY_TEX_UV] = geom.uvs
	if geom.has("colors"): arrays[Mesh.ARRAY_COLOR] = geom.colors
	
	RenderingServer.mesh_add_surface_from_arrays(mesh_rid, RenderingServer.PRIMITIVE_TRIANGLES, arrays)

func _update_collision(coord: Vector3i, geom: Dictionary) -> void:
	var chunk = active_chunks[coord]
	if chunk.body.is_valid(): PhysicsServer3D.free_rid(chunk.body)
	
	chunk.body = PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(chunk.body, PhysicsServer3D.BODY_MODE_STATIC)
	PhysicsServer3D.body_set_space(chunk.body, get_world_3d().space)
	
	var shape := PhysicsServer3D.concave_polygon_shape_create()
	
	# FIX: Explicitly define the dictionary with the 'backface_collision' boolean
	var shape_data := {
		"faces": geom.vertices,
		"backface_collision": false
	}
	
	PhysicsServer3D.shape_set_data(shape, shape_data)
	PhysicsServer3D.body_add_shape(chunk.body, shape)
	
	PhysicsServer3D.body_set_state(chunk.body, PhysicsServer3D.BODY_STATE_TRANSFORM, 
		Transform3D(Basis(), VoxelEngineHexagon.chunk_to_world(coord, chunk_size)))
	
	chunk.shape = shape

# === Helpers ===

func _get_neighbors_to_update(local: Vector3i) -> Array[Vector3i]:
	var neighbors: Array[Vector3i] = []
	if local.x == 0: neighbors.append(Vector3i(-1, 0, 0))
	elif local.x == chunk_size - 1: neighbors.append(Vector3i(1, 0, 0))
	if local.y == 0: neighbors.append(Vector3i(0, -1, 0))
	elif local.y == chunk_size - 1: neighbors.append(Vector3i(0, 1, 0))
	if local.z == 0: neighbors.append(Vector3i(0, 0, -1))
	elif local.z == chunk_size - 1: neighbors.append(Vector3i(0, 0, 1))
	return neighbors

func _update_highlight_mesh() -> void:
	highlight_mesh_instance.mesh = null
	
	var hex_mesh := CylinderMesh.new()
	hex_mesh.radial_segments = 6
	hex_mesh.cap_top = true
	hex_mesh.cap_bottom = true
	hex_mesh.top_radius = 1.0
	hex_mesh.bottom_radius = 1.0
	hex_mesh.height = 1.0
	highlight_mesh_instance.mesh = hex_mesh
