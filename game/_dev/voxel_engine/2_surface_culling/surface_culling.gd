class_name VoxelEngineSurfaceCulling
extends Node3D

@export var use_hexagons: bool = true
@export var dimensions: Vector3 = Vector3(32, 32, 32)
@export var cutoff: float = 0.5
@export var colors: Array[Color] = [Color.PURPLE, Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN, Color.ORANGE]

@onready var cube_mesh: VoxelEngineSurfaceCullingCubeMesh = $Cube
@onready var hexagon_mesh: VoxelEngineSurfaceCullingHexagonMesh = $Hexagon

var total_blocks: int = 0
var cube_data: Dictionary[Vector3, Color] = {}
var hexagon_data: Dictionary[Vector3i, Color] = {}

func _ready() -> void:
	var start_time = Time.get_ticks_usec()
	
	if use_hexagons:
		_generate_hexagon_data()
		hexagon_mesh.generate_mesh(hexagon_data)
	else:
		_generate_cube_data()
		cube_mesh.generate_mesh(cube_data)
		
	_print_debug(start_time)

func _print_debug(start_time: float) -> void:
	var end_time = Time.get_ticks_usec()
	print("Surface - Blocks: %d | Time: %f" % [total_blocks, (end_time - start_time) / 1_000_000.0])

func _get_random_color(y: int) -> Color:
	return colors[y % colors.size()]

func _generate_cube_data() -> void:
	var random = FastNoiseLite.new()
	random.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	for x in int(dimensions.x):
		for z in int(dimensions.z):
			for y in int(dimensions.y):
				if random.get_noise_3d(x, y, z) > cutoff:
					cube_data.set(Vector3(x, y, z), _get_random_color(y))
					total_blocks += 1

func _generate_hexagon_data() -> void:
	var random = FastNoiseLite.new()
	random.noise_type = FastNoiseLite.TYPE_SIMPLEX
	for x in range(dimensions.x):
		for z in range(dimensions.z):
			for y in range(dimensions.y):
				if random.get_noise_3d(x, y, z) > cutoff:
					hexagon_data.set(
						Vector3i(x, y, z), 
						_get_random_color(y)
					)
					total_blocks += 1
