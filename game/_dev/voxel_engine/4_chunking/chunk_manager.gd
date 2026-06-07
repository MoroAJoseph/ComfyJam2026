class_name VoxelEnigneChunkingChunkManager
extends Node

@export var use_hexagons: bool = false
@export var dimensions: Vector3 = Vector3(64, 16, 64)
@export var chunk_size: int = 64
@export var noise_seed: int = 0
@export var cube_chunk_scene: PackedScene
@export var hexagon_chunk_scene: PackedScene
@export var colors : Array[Color] = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.YELLOW
]

var total_chunks: Vector3
var total_voxels: int
var total_rendered_voxels: int
var total_collision_shapes: int
var noise = FastNoiseLite.new()
var start_time: float
var voxels_mutex = Mutex.new()
var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var chunks_processed: int = 0

func _ready() -> void:
	Performance.add_custom_monitor(
		"voxel_engine/total_voxels",
		func(): return total_voxels
	)
	Performance.add_custom_monitor(
		"voxel_engine/rendered_voxels",
		func(): return total_rendered_voxels
	)
	Performance.add_custom_monitor(
		"voxel_engine/collision_shapes",
		func(): return total_collision_shapes
	)
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.003
	noise.seed = noise_seed
	
	# only works if dimensions are divisible by chunk size
	total_chunks.x = ceil(dimensions.x / float(chunk_size))
	total_chunks.y = ceil(dimensions.y / float(chunk_size))
	total_chunks.z = ceil(dimensions.z / float(chunk_size))
	
	start_time = Time.get_ticks_usec()
	WorkerThreadPool.add_task(func(): generate_chunks())

func generate_chunks() -> void:
	print("Total chunks: ", total_chunks)
	for x in range(total_chunks.x):
		for z in range(total_chunks.z):
			for y in range(total_chunks.y):
				call_deferred("_spawn_chunk", Vector3(x, y, z) * chunk_size)

func _spawn_chunk(pos: Vector3) -> void:
	var new_chunk = cube_chunk_scene.instantiate()
	new_chunk.position = pos
	add_child(new_chunk)
	
	WorkerThreadPool.add_task(func(): _process_chunk_data(new_chunk, pos))

func _process_chunk_data(chunk: Node3D, pos: Vector3) -> void:
	var chunk_coords := Vector3i(pos / chunk_size)
	var voxels: PackedByteArray = chunk.generate_mesh(chunk_size, int(dimensions.y), noise, colors, pos)
	
	var local_total_voxels = 0
	for b in voxels: if b > 0: local_total_voxels += 1
	
	voxels_mutex.lock()
	chunks_data[chunk_coords] = voxels
	total_voxels += local_total_voxels
	voxels_mutex.unlock()
	
	var surface_count: int = chunk.prepare_mesh_data(chunk_coords, chunks_data, chunk_size, colors)
	
	voxels_mutex.lock()
	chunks_data[chunk_coords] = voxels
	total_voxels += local_total_voxels
	total_rendered_voxels += surface_count
	total_collision_shapes += 1
	chunks_processed += 1
	var finished = (chunks_processed == int(total_chunks.x * total_chunks.y * total_chunks.z))
	voxels_mutex.unlock()
	
	chunk.call_deferred("apply_prepared_mesh")
	chunk.call_deferred("apply_collision")
	
	if finished:
		call_deferred("_print_debug")

func _print_debug() -> void:
	var end_time = Time.get_ticks_usec()
	print("----- Chunk Performance -----")
	print("- Voxels: ", total_voxels)
	print("- Rendered Voxels: ", total_rendered_voxels)
	print("- Collision Shapes: ", total_collision_shapes)
	print("- Total Time: ", (end_time - start_time) / 1_000_000.0)
