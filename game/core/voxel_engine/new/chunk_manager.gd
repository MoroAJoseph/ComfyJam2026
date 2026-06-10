class_name NewVoxelEngineChunkManager extends Node3D

enum VoxelType { CUBE, HEXAGON }

@export_group("Generation Settings")
@export var voxel_type: VoxelType
@export var use_collision: bool = false
@export var chunk_size: int = 64
@export var render_radius: int = 5
@export var noise: FastNoiseLite
@export var context_target: Node3D
@export var sea_level: int = 8

var logic_class: Object
var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var active_chunk_nodes: Dictionary[Vector3i, NewVoxelEngineChunk] = {}
var rid_to_coordinate: Dictionary[RID, Vector3i] = {} # For Interactor lookup
var pooled_chunks: Array[NewVoxelEngineChunk] = []
var loading_chunks: Dictionary[Vector3i, bool] = {}
var current_player_chunk: Vector3i = Vector3i.ZERO

# ===
# Built-In
# ===

func _ready() -> void:
	match voxel_type:
		VoxelType.CUBE: logic_class = VoxelEngineCube
		VoxelType.HEXAGON: logic_class = VoxelEngineHexagon
	

func _process(_delta: float) -> void:
	if not context_target: return
	
	var new_coord = logic_class.world_to_chunk(context_target.global_position, chunk_size)
	if new_coord != current_player_chunk:
		current_player_chunk = new_coord
		update_render_distance()

# ===
# Public
# ===

func start_engine() -> void:
	# Ensure noise is set up
	if not noise:
		noise = FastNoiseLite.new()
		noise.seed = randi()
		
	# Populate initial chunks
	current_player_chunk = logic_class.world_to_chunk(context_target.global_position, chunk_size)
	update_render_distance()

func update_render_distance() -> void:
	var needed = _get_nearby_coordinates(render_radius)
	
	for coord in needed:
		if not active_chunk_nodes.has(coord) and not loading_chunks.has(coord):
			_spawn_chunk(coord)
			
	for coord in active_chunk_nodes.keys():
		if not coord in needed:
			_recycle_chunk(coord)

func remove_voxel(coord: Vector3i, local_voxel: Vector3i) -> void:
	var data = chunks_data.get(coord)
	if not data: return
	
	var idx = logic_class.get_index(local_voxel.x, local_voxel.y, local_voxel.z, chunk_size)
	data[idx] = 0
	_generate_and_apply(coord, active_chunk_nodes[coord])

# ===
# Private
# ===

func _spawn_chunk(coord: Vector3i) -> void:
	loading_chunks[coord] = true
	
	var chunk: NewVoxelEngineChunk
	if not pooled_chunks.is_empty():
		chunk = pooled_chunks.pop_back()
	else:
		chunk = NewVoxelEngineChunk.new()
		add_child(chunk)
	
	chunk.position = logic_class.chunk_to_world(coord, chunk_size)
	chunk.show()
	active_chunk_nodes[coord] = chunk
	
	var collision_enabled = use_collision
	WorkerThreadPool.add_task(func(): 
		if not chunks_data.has(coord):
			chunks_data[coord] = NewVoxelEngineGenerator.generate_raw_voxels(
				logic_class.chunk_to_world(coord, chunk_size),
				chunk_size, noise, 50, sea_level, logic_class
			)
		_generate_and_apply(coord, chunk)
	)

func _generate_and_apply(coord: Vector3i, chunk: NewVoxelEngineChunk) -> void:
	var data = chunks_data.get(coord)
	var geo = logic_class.calculate_geometry(data, coord, chunks_data, chunk_size, [])
	call_deferred("_finalize_chunk", coord, chunk, geo, use_collision)

func _finalize_chunk(coord: Vector3i, chunk: NewVoxelEngineChunk, geo: Dictionary, use_col: bool) -> void:
	loading_chunks.erase(coord)
	if active_chunk_nodes.get(coord) == chunk:
		chunk.update_state(geo, use_col) # Respect the flag
		if use_col:
			rid_to_coordinate[chunk.get_collision_rid()] = coord

func _recycle_chunk(coord: Vector3i) -> void:
	var chunk = active_chunk_nodes[coord]
	# Cleanup mapping before hiding
	rid_to_coordinate.erase(chunk.get_collision_rid())
	
	chunk.update_state({"vertices": [], "normals": [], "colors": []}, false)
	chunk.hide()
	pooled_chunks.append(chunk)
	active_chunk_nodes.erase(coord)

func _get_nearby_coordinates(radius: int) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	for x in range(-radius, radius + 1):
		for z in range(-radius, radius + 1):
			if Vector2(x, z).length() <= radius:
				result.append(current_player_chunk + Vector3i(x, 0, z))
	return result
