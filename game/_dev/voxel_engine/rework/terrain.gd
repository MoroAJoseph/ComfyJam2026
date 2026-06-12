class_name Terrain 
extends Node3D

@export var wireframe: bool = false: set = set_wireframe
@export var dimensions: Vector3 = Vector3i(128, 64, 128)
@export var color_array: Dictionary[TerrainAlgorithm.Voxel, Color]

@onready var chunk_manager: ChunkManager = $ChunkManager

var loading_threads: Array[Thread] = [Thread.new()]

func _ready() -> void:
	if wireframe: 
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
		
	chunk_manager.terrain_algorithm.max_height = dimensions.y
	chunk_manager.meshing_algorithm.SetColors(color_array)
	
	# Pass index context (0,0,0) instead of a world coordinate vector directly
	loading_threads[0].start(generate_chunks.bind(Vector3i.ZERO))

func set_wireframe(enabled: bool) -> void:
	wireframe = enabled
	if wireframe: 
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	else:
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
	
func generate_chunks(base_grid_offset: Vector3i) -> void:
	var number_of_chunks = Vector3i(
		ceil(dimensions.x / float(chunk_manager.chunk_size)) as int,
		ceil(dimensions.y / float(chunk_manager.chunk_size)) as int,
		ceil(dimensions.z / float(chunk_manager.chunk_size)) as int
	)
	
	for x in range(number_of_chunks.x):
		for z in range(number_of_chunks.z):
			for y in range(number_of_chunks.y):
				var chunk_grid_index = Vector3i(x, y, z) + base_grid_offset
				# FIX: Pass the abstract grid tracker down instead of hardcoding linear offsets
				chunk_manager.generate_chunk(chunk_grid_index)

func _exit_tree() -> void:
	for thread in loading_threads:
		if thread.is_started():
			thread.wait_to_finish()

#func _unhandled_key_input(event) -> void:
	#if event.is_action_pressed("wireframe"):
		#wireframe = !wireframe
