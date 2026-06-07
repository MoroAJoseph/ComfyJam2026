class_name VoxelEngineMultiThreaded
extends Node3D

@export var use_hexagons: bool = true
@export var dimensions: Vector3 = Vector3(32, 32, 32)
@export var cutoff: float = 0.5
@export var colors: Array[Color] = [Color.PURPLE, Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN, Color.ORANGE]

@onready var cube_mesh: VoxelEngineMultiThreadedCubeMesh = $Cube
@onready var hexagon_mesh: VoxelEngineMultiThreadedHexagonMesh = $Hexagon

var start_time: float
var total_blocks: int = 0
var cube_data: Dictionary[Vector3, Color] = {}
var hexagon_data: Dictionary[Vector3i, Color] = {}

func _ready() -> void:
	start_time = Time.get_ticks_usec()
	
	WorkerThreadPool.add_task(func(): _run_threaded_generation())

func _print_debug() -> void:
	var end_time = Time.get_ticks_usec()
	print("Surface - Blocks: %d | Time: %f" % [total_blocks, (end_time - start_time) / 1_000_000.0])

func _get_random_color(y: int) -> Color:
	return colors[y % colors.size()]

func _generate_cube_data() -> void:
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	for x in int(dimensions.x):
		for z in int(dimensions.z):
			for y in int(dimensions.y):
				
				if noise.get_noise_3d(x, y, z) > cutoff:
					cube_data.set(Vector3(x, y, z), _get_random_color(y))
					total_blocks += 1

func _generate_hexagon_data() -> void:
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	for x in range(dimensions.x):
		for z in range(dimensions.z):
			for y in range(dimensions.y):
				
				var height_factor = float(y) / float(dimensions.y)
				if noise.get_noise_3d(x, y, z) > (cutoff + (height_factor * 0.5)):
					hexagon_data[Vector3i(x, y, z)] = _get_random_color(y)
					total_blocks += 1

func _run_threaded_generation() -> void:
	if use_hexagons:
		_generate_hexagon_data()
		hexagon_mesh.prepare_mesh_data(hexagon_data)
		call_deferred("finalize_mesh")
	else:
		_generate_cube_data()
		cube_mesh.prepare_mesh_data(cube_data)
		call_deferred("finalize_mesh")

func finalize_mesh() -> void:
	if use_hexagons: hexagon_mesh.apply_prepared_mesh()
	else: cube_mesh.apply_prepared_mesh()
	_print_debug()
