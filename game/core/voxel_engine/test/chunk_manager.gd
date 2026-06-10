class_name TestVoxelEngineChunkManager extends Node3D

@export_group("Settings")
@export var chunk_size: int = 64
@export var render_radius: int = 5
@export var context_target: Node3D
@export var material: Material

@export_group("Generation")
@export var noise: FastNoiseLite
@export var colors: Array[Color] = [Color.RED, Color.GREEN, Color.BLUE]
@export var logic_class: GDScript = VoxelEngineHexagon

var active_chunks: Dictionary[Vector3i, TestVoxelEngineChunk] = {}
var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var current_player_chunk: Vector3i = Vector3i.ZERO

func _ready() -> void:
	# Small delay to ensure the scene is ready and context_target exists
	await get_tree().process_frame
	if context_target:
		current_player_chunk = logic_class.world_to_chunk(context_target.global_position, chunk_size)
		_update_render_distance()

func _process(_delta: float) -> void:
	if not context_target: return
	
	var new_coord = logic_class.world_to_chunk(context_target.global_position, chunk_size)
	if new_coord != current_player_chunk:
		current_player_chunk = new_coord
		_update_render_distance()

func _update_render_distance() -> void:
	var needed: Array[Vector3i] = []
	
	# Correct Hexagon Spiral Iteration
	# Instead of standard square loops, iterate in axial coordinates
	for q in range(-render_radius, render_radius + 1):
		for r in range(-render_radius, render_radius + 1):
			if abs(q + r) <= render_radius: 
				needed.append(current_player_chunk + Vector3i(q, 0, r))
	
	# Sync Logic
	for coord in needed:
		if not active_chunks.has(coord):
			_spawn_chunk(coord)
			
	for coord in active_chunks.keys():
		if not coord in needed:
			_remove_chunk(coord)

func _is_within_hex_radius(hex_coord: Vector3i, radius: int) -> bool:
	# Hexagonal distance formula
	var dist = (abs(hex_coord.x) + abs(hex_coord.x + hex_coord.z) + abs(hex_coord.z)) / 2
	return dist <= radius

func _get_neighbors(coord: Vector3i) -> Array:
	# Add your hex neighbor logic here
	var neighbors = []
	for offset in VoxelEngineHexagon.FACE_TO_NEIGHBOR:
		neighbors.append(coord + offset)
	return neighbors

func _spawn_chunk(coord: Vector3i) -> void:
	# Always ensure data exists BEFORE spawning
	if not chunks_data.has(coord):
		var origin = logic_class.chunk_to_world(coord, chunk_size)
		chunks_data[coord] = TestVoxelEngineGenerator.generate_chunk_data(origin, noise, chunk_size, 32, colors, logic_class)
	
	# Create an immutable snapshot for the thread
	var target_data = chunks_data[coord]
	var neighbors_snapshot = {}
	for n in _get_neighbors(coord):
		if chunks_data.has(n):
			neighbors_snapshot[n] = chunks_data[n]

	WorkerThreadPool.add_task(func():
		# Pass the snapshot, NOT the main dictionary
		var geo = TestVoxelEngineMeshBuilder.build_geometry(target_data, coord, neighbors_snapshot, chunk_size, colors, logic_class)
		call_deferred("_finalize_chunk", coord, target_data, geo)
	)

func _finalize_chunk(coord: Vector3i, data: PackedByteArray, geo: Dictionary) -> void:
	chunks_data[coord] = data
	var chunk = TestVoxelEngineChunk.new(material)
	add_child(chunk)
	chunk.global_transform.origin = logic_class.chunk_to_world(coord, chunk_size)
	chunk.update_visuals(geo)
	active_chunks[coord] = chunk

func _remove_chunk(coord: Vector3i) -> void:
	if active_chunks.has(coord):
		active_chunks[coord].queue_free()
		active_chunks.erase(coord)
		chunks_data.erase(coord)
