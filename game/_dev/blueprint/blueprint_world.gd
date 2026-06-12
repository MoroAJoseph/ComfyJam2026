@tool
class_name BlueprintWorld
extends Control

@export_category("Settings")
@export var data_resource: BlueprintWorldData
@export var grid_size: int = 64
@export var world_radius: int = 2048

# Editor Buttons
@export var generate_world: bool: set = _run_generation_trigger
@export var save_world_data: bool: set = _save_to_resource

@onready var status_label: Label = $VBoxContainer/Status
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

# --- LOCAL BUFFERS (Invisible to Inspector, avoids read-only locks) ---
var _local_matrix: Dictionary = {}
var _island_blueprints: Array[Dictionary] = []

func _run_generation_trigger(_value: bool) -> void:
	if not data_resource: return
	
	# Sort zones to ensure they are processed from inner-most to outer-most
	var local_zones: Array = data_resource.world_zone_data.duplicate()
	local_zones.sort_custom(func(a: WorldZoneData, b: WorldZoneData) -> bool: return a.radius < b.radius)
	
	_local_matrix = {}
	_island_blueprints = []
	
	# Pass the sorted zones to the generator
	await _run_generation(local_zones)

func _run_generation(sorted_zones: Array) -> void:
	status_label.text = "Generating island locations..."
	var prev_radius: float = 0.0
	
	for zone in sorted_zones:
		var count: int = 10 # Configure based on your logic
		for i in range(count):
			var world_pos: Vector2 = _get_random_pos_in_zone(prev_radius, float(zone.radius))
			_island_blueprints.append({
				"position": world_pos,
				"zone": zone,
				"data": _generate_island_data(world_pos, zone)
			})
			progress_bar.value = (float(i) / float(count)) * 100.0
			await get_tree().process_frame
		prev_radius = float(zone.radius)
	
	_bake_to_local_matrix()
	_print_zone_statistics(sorted_zones)
	status_label.text = "Generation complete. Ready to save."

func _bake_to_local_matrix() -> void:
	for blueprint in _island_blueprints:
		var world_offset: Vector2 = blueprint.position
		for voxel_pos in blueprint.data.block_map:
			var world_v_pos: Vector3 = Vector3(world_offset.x + voxel_pos.x, voxel_pos.y, world_offset.y + voxel_pos.z)
			var coord: Vector2i = Vector2i(int(floor(world_v_pos.x / grid_size)), int(floor(world_v_pos.z / grid_size)))
			
			if not _local_matrix.has(Vector3i(coord.x, 0, coord.y)):
				_local_matrix[Vector3i(coord.x, 0, coord.y)] = {}
			
			var local_pos: Vector3i = Vector3i(int(world_v_pos.x) % grid_size, int(world_v_pos.y), int(world_v_pos.z) % grid_size)
			_local_matrix[Vector3i(coord.x, 0, coord.y)][local_pos] = blueprint.data.block_map[voxel_pos]

func _print_zone_statistics(sorted_zones: Array) -> void:
	print("\n" + "=".repeat(40))
	print("WORLD GENERATION ZONE REPORT")
	print("=".repeat(40))
	
	for i in range(sorted_zones.size()):
		var zone: WorldZoneData = sorted_zones[i]
		var islands = _island_blueprints.filter(func(b): return b.zone == zone)
		
		print("Zone Index: %d" % i)
		print("  Radius: %d" % zone.radius)
		print("  Size Range: %s to %s" % [zone.min_island_size, zone.max_island_size])
		print("  Flatness: %.2f to %.2f" % [zone.min_island_flatness, zone.max_island_flatness])
		print("  Islands: %d" % islands.size())
		
		print("  Docks:")
		for d in range(zone.dock_count):
			print("    Dock %d: %s" % [d, _get_random_pos_in_zone(0, float(zone.radius))])
		print("-".repeat(20))

func _save_to_resource(_value: bool) -> void:
	if not data_resource: return
	
	# ATOMIC SYNC: Copy local buffer to Resource property in one operation
	var final_matrix: Dictionary[Vector3i, PackedInt32Array] = {}
	for coord in _local_matrix:
		final_matrix[coord] = _pack_chunk(_local_matrix[coord])
	
	data_resource.chunk_matrix = final_matrix
	ResourceSaver.save(data_resource, data_resource.resource_path)
	status_label.text = "World saved to: %s" % data_resource.resource_path

func _pack_chunk(block_map: Dictionary) -> PackedInt32Array:
	var arr: PackedInt32Array = PackedInt32Array()
	arr.resize(64 * 64 * 64)
	arr.fill(0)
	for pos in block_map:
		var index: int = pos.x + (pos.y * 64) + (pos.z * 4096)
		arr[index] = block_map[pos]
	return arr

func _generate_island_data(world_pos: Vector2, zone: WorldZoneData) -> VoxelEngineBlueprintData:
	var seed_val: int = hash(world_pos)
	var dims: Vector3i = Vector3i(randi_range(zone.min_island_size.x, zone.max_island_size.x), 
								  randi_range(zone.min_island_size.y, zone.max_island_size.y), 
								  randi_range(zone.min_island_size.z, zone.max_island_size.z))
	var flatness: float = randf_range(zone.min_island_flatness, zone.max_island_flatness)
	var weights: Array[float] = []
	for i in range(zone.dock_count): weights.append(1.0)
	
	var heightmap: Array[float] = VoxelEngineBlueprintGenerator.generate_dock_island(Vector2i(dims.x, dims.z), seed_val, weights, flatness, dims.y)
	var data: VoxelEngineBlueprintData = VoxelEngineBlueprintData.new()
	data.block_map = VoxelEngineBlueprintGenerator.generate_dock_voxels(heightmap, dims, 1.0, seed_val, 2.5, [1.0], [])
	return data

func _get_random_pos_in_zone(min_r: float, max_r: float) -> Vector2:
	var angle: float = randf() * TAU
	var dist: float = randf_range(min_r, max_r)
	return Vector2.from_angle(angle) * dist
