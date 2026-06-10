class_name DEVVoxelEngineRoot
extends Node

signal hovered_voxel_updated()
signal hovered_chunk_updated()

@export_group("Config")
@export var use_collision: bool = true
@export var use_highlighter: bool = true
@export var hover_ray_distance: float = 100.0

@export_group("Generation Settings")
@export var chunk_size: int = 64
@export var generation_height: int = 16
@export var generation_radius: int = 5
@export var render_radius: int = 5
@export var physics_radius: int = 2

@export_group("Terrain Settings")
@export var voxel_type: VoxelEngineEnums.VoxelType
@export var noise: FastNoiseLite
@export var noise_seed: int = 0
@export var sea_level: int = 8
@export var voxel_colors: Array[Color] = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.ORANGE,
	Color.PURPLE,
	Color.YELLOW
]

var build_context: DEVVoxelEngineBuildContext
var voxel_class: VoxelEngineVoxel
var chunk_manager: DEVVoxelEngineChunkManager
var highlighter: DEVVoxelEngineHighlighter
var hover_interface: DEVVoxelEngineHoverInterface
@export var player: Node3D

# ===
# Built-In
# ===

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = noise_seed
	build_context = DEVVoxelEngineBuildContext.new()
	build_context.chunk_size = chunk_size
	_update_voxel_class()
	if player:
		build()

func _process(_delta: float) -> void:
	if not (
		player and 
		chunk_manager and
		build_context.chunks_data
	): return
	
	# Update Rendered Chunk Radius
	var new_chunk_coord: Vector3i = voxel_class.world_to_chunk(
		player.global_position,
		chunk_size
	)
	
	if new_chunk_coord != build_context.current_player_chunk:
		build_context.current_player_chunk = new_chunk_coord
		chunk_manager.update_rendered_chunks(
			render_radius
		)

# ===
# Public
# ===

func update_player(value: Node3D) -> void:
	player = value
	build_context.player = value

func build() -> void:
	# Generate Data
	var start_time: int = Time.get_ticks_msec()
	build_context.chunks_data = generate_world_data()
	var end_time: int = Time.get_ticks_msec()
	var duration_seconds: float = (end_time - start_time) / 1_000.0
	
	print_debug("Build complete in %.3f seconds." % duration_seconds)
	print_debug("Total voxels in generated world data: %d" % build_context.get_total_voxel_count())
	
	# Chunk Manager
	chunk_manager = DEVVoxelEngineChunkManager.new(
		build_context
	)
	add_child(chunk_manager)
	
	# Highlighter
	highlighter = DEVVoxelEngineHighlighter.new(
		build_context
	)
	add_child(highlighter)
	
	# Hover Interface
	hover_interface = DEVVoxelEngineHoverInterface.new(
		build_context, 
		hover_ray_distance
	)
	add_child(hover_interface)

func generate_world_data() -> Dictionary[Vector3i, PackedByteArray]:
	var data: Dictionary[Vector3i, PackedByteArray] = {}
	var y_max: int = int(ceil(generation_height / float(chunk_size)))
	
	for x: int in range(-generation_radius, generation_radius + 1):
		for z: int in range(-generation_radius, generation_radius + 1):
			if Vector2(x, z).length() <= generation_radius:
				for y: int in range(0, y_max):
					var coordinate: Vector3i = Vector3i(x, y, z)
					var coordinate_too_world: Vector3i = voxel_class.chunk_to_world(
						coordinate, 
						chunk_size
					)
					data[coordinate] = generate_raw_voxels(
						coordinate_too_world
					)
	return data

func generate_raw_voxels(origin: Vector3) -> PackedByteArray:
	var voxels: PackedByteArray = PackedByteArray()

	voxels.resize(chunk_size * chunk_size * chunk_size)
	voxels.fill(0)

	for x in range(chunk_size):
		for z in range(chunk_size):
			for y in range(chunk_size):

				var world_pos = origin + voxel_class.voxel_to_world(
					Vector3i(x,y,z),
					Vector3.ZERO
				)

				var density := noise.get_noise_3d(
					world_pos.x,
					world_pos.y,
					world_pos.z
				)

				var height_gradient = (
					world_pos.y /
					float(generation_height)
				)

				var final_density = density - height_gradient

				if final_density > 0.0 and world_pos.y >= sea_level:

					var voxel_type := 1

					if world_pos.y < sea_level + 2:
						voxel_type = 3
					elif world_pos.y < sea_level + 5:
						voxel_type = 2

					voxels[
						x +
						(y * chunk_size) +
						(z * chunk_size * chunk_size)
					] = voxel_type

	return voxels

# ===
# Private
# ===

func _update_voxel_class() -> void:
	match voxel_type:
		VoxelEngineEnums.VoxelType.CUBE:
			voxel_class = VoxelEngineCube.new()
		VoxelEngineEnums.VoxelType.HEXAGON:
			voxel_class = VoxelEngineHexagon.new()
	
	build_context.voxel_class = voxel_class
