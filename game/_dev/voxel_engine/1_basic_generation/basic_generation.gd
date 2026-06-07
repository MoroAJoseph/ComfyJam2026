class_name VoxelEngineBasicGeneration
extends Node3D

@export var use_hexagons: bool = true
@export var dimensions: Vector3 = Vector3(32, 32, 32)
@export var cutoff: float = 0.5
@export var colors: Array[Color] = [
	Color.PURPLE,
	Color.RED,
	Color.BLUE,
	Color.YELLOW,
	Color.GREEN,
	Color.ORANGE
]

@onready var cube_mesh: VoxelEngineBasicCubeMesh = $Cube
@onready var hexagon_mesh: VoxelEngineBasicHexagonMesh = $Hexagon

var total_blocks: int = 0
var cube_data: Dictionary[Vector3, Color] = {}
var hexagon_data: Dictionary[Vector3, Color] = {}
var collision_shape: CollisionShape3D

func _ready() -> void:
	Performance.add_custom_monitor(
		"game/blocks", 
		func(): return total_blocks
	)
	
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
	print("Basic - Blocks: %d | Time: %f" % [total_blocks, (end_time - start_time) / 1_000_000.0])

func _get_random_color(y: int) -> Color:
	return colors[y % colors.size()]

func _generate_cube_data() -> void:
	var random = FastNoiseLite.new()
	random.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	for x in range(dimensions.x):
		for z in range(dimensions.z):
			for y in range(dimensions.y):
				var rand = random.get_noise_3d(x, y, z)
				if rand > cutoff:
					cube_data.set(Vector3(x, y, z), _get_random_color(y))
					total_blocks += 1

func _generate_hexagon_data() -> void:
	var random = FastNoiseLite.new()
	random.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	var radius = 1.0
	var apothem = radius * (sqrt(3.0) / 2.0)
	
	# Horizontal spacing is 2 * apothem for flat-topped
	var x_spacing = apothem * 2.0
	# Vertical spacing (row-to-row) is 1.5 * radius
	var z_spacing = radius * 1.5
	
	for x in range(dimensions.x):
		for z in range(dimensions.z):
			# Calculate base position
			var world_x = x * x_spacing
			var world_z = z * z_spacing
			
			# Offset every other row (z) by the apothem to interlock
			if z % 2 != 0:
				world_x += apothem
				
			for y in range(dimensions.y):
				if random.get_noise_3d(x, y, z) > cutoff:
					hexagon_data.set(Vector3(world_x, y, world_z), _get_random_color(y))
					total_blocks += 1
