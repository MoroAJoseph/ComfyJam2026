@tool
class_name VoxelBlueprintWorldZones
extends Node3D

const BLOCK_COLORS: Dictionary = {
	Enums.BlockType.SAND: Color.ANTIQUE_WHITE,
	Enums.BlockType.DIRT: Color.SADDLE_BROWN,
	Enums.BlockType.STONE: Color.SLATE_GRAY,
	Enums.BlockType.COBBLESTONE: Color.DARK_GRAY,
	Enums.BlockType.MOSSY_COBBLESTONE: Color.FOREST_GREEN,
	Enums.BlockType.GRASS: Color.WEB_GREEN,
	Enums.BlockType.COAL_ORE: Color.DIM_GRAY,
	Enums.BlockType.COAL: Color.BLACK,
	Enums.BlockType.SILVER_ORE: Color.LIGHT_GRAY,
	Enums.BlockType.COPPER_ORE: Color.ORANGE_RED
}

@export_category("Step 1: Settings")
@export var data_resource: VoxelBlueprintWorldData
@export var chunk_size: int = 64
@export var use_hexagons: bool = false
@export var world_seed: int

@export_category("Step 2: Generate")
@export var generate: bool: set = _run_generation_trigger

@export_category("Step 3: Preview")
@export var preview: bool: set = _preview_trigger

@export_category("Step 4: Save")
@export var save_world_data: bool: set = _save_to_resource

@onready var status_label: Label = $Control/VBoxContainer/Status
@onready var progress_bar: ProgressBar = $Control/VBoxContainer/ProgressBar

var _local_matrix: Dictionary = {}
var _island_blueprints: Array[Dictionary] = []
var _rng: RandomNumberGenerator
var _zone_spawn_profiles: Dictionary = {}

func _ready() -> void:
	_rng = _get_rng()

func _get_rng() -> RandomNumberGenerator:
	if not _rng:
		_rng = RandomNumberGenerator.new()
		_rng.seed = world_seed
	return _rng

func _run_generation_trigger(_value: bool) -> void:
	print_debug("ok")
	if not data_resource: 
		push_error("No Data Resource assigned!")
		return
	
	# Debug check
	if status_label:
		status_label.text = "Generating..."
	else:
		print("Status label is null! Check your node path.")
		
	_rng = _get_rng() # Ensure RNG is fresh
	_rng.seed = world_seed
	
	var result: Dictionary = VoxelBlueprintWorldGenerator.generate_world(data_resource, _rng)
	
	# Cast safely
	_island_blueprints = []
	for bp in result.blueprints:
		_island_blueprints.append(bp as Dictionary)
	
	# =====
	# DEBUG
	# =====
	
	for i in range(_island_blueprints.size()):
		var a = _island_blueprints[i]

		var rect_a = Rect2i(
			a["anchor"].x,
			a["anchor"].y,
			a["dims"].x,
			a["dims"].z
		)

		for j in range(i + 1, _island_blueprints.size()):
			var b = _island_blueprints[j]

			var rect_b = Rect2i(
				b["anchor"].x,
				b["anchor"].y,
				b["dims"].x,
				b["dims"].z
			)

			if rect_a.intersects(rect_b):
				push_error(
				    "OVERLAP %d <-> %d\nA=%s\nB=%s"
					% [i, j, rect_a, rect_b]
				)
	
	
	# =====
	# DEBUG
	# =====

	_bake_to_local_matrix()
	
	var sorted_zones = data_resource.world_zone_data.duplicate()
	sorted_zones.sort_custom(func(a, b): return a.radius < b.radius)
	_print_zone_statistics(sorted_zones)
	
	if status_label:
		status_label.text = "Generation complete."

func _bake_to_local_matrix() -> void:
	_local_matrix = {}
	var global_occupancy := {}
	var voxel_overlap_count := 0

	for blueprint in _island_blueprints:

		var anchor: Vector2i = blueprint["anchor"]
		var dims: Vector3i = blueprint["dims"]
		var is_dock: bool = blueprint.get("is_dock", false)

		for local_voxel_pos: Vector3i in blueprint.voxels:

			if local_voxel_pos.x < 0 or local_voxel_pos.x >= dims.x:
				continue
			if local_voxel_pos.z < 0 or local_voxel_pos.z >= dims.z:
				continue

			var q := anchor.x + local_voxel_pos.x
			var r := anchor.y + local_voxel_pos.z
			var y := local_voxel_pos.y

			var voxel_key := Vector3i(q, y, r)

			if global_occupancy.has(voxel_key):
				voxel_overlap_count += 1
				continue

			global_occupancy[voxel_key] = true

			var chunk_coord := Vector3i(
				floori(q / chunk_size),
				0,
				floori(r / chunk_size)
			)

			var local_key := Vector3i(
				posmod(q, chunk_size),
				y,
				posmod(r, chunk_size)
			)

			if not _local_matrix.has(chunk_coord):
				_local_matrix[chunk_coord] = {
					"voxels": {},
					"is_dock": false
				}

			if is_dock:
				_local_matrix[chunk_coord]["is_dock"] = true

			_local_matrix[chunk_coord]["voxels"][local_key] = blueprint.voxels[local_voxel_pos]

	print("Voxel overlaps: ", voxel_overlap_count)

func _save_to_resource(_value: bool) -> void:
	if not data_resource: return
	for coord in _local_matrix: 
		data_resource.chunk_matrix[coord] = _pack_chunk(_local_matrix[coord])
	ResourceSaver.save(data_resource, data_resource.resource_path)
	status_label.text = "Saved."

func _preview_trigger(_value: bool) -> void:
	_clear_preview()

	var parent_node := Node3D.new()
	parent_node.name = "GeneratedIslands"
	add_child(parent_node)

	if Engine.is_editor_hint():
		parent_node.owner = get_tree().edited_scene_root

	var edge_alignment_basis := Basis.from_euler(
		Vector3(0, deg_to_rad(30), 0)
	)

	for blueprint in _island_blueprints:

		var anchor: Vector2i = blueprint["anchor"]
		var voxels: Dictionary = blueprint["voxels"]
		var is_dock: bool = blueprint.get("is_dock", false)

		var blocks_by_type := {}

		for voxel_pos in voxels:
			var block_type = voxels[voxel_pos]

			if not blocks_by_type.has(block_type):
				blocks_by_type[block_type] = []

			blocks_by_type[block_type].append(voxel_pos)

		for block_type in blocks_by_type:

			var positions: Array = blocks_by_type[block_type]

			var mm_instance := MultiMeshInstance3D.new()
			parent_node.add_child(mm_instance)

			if Engine.is_editor_hint():
				mm_instance.owner = get_tree().edited_scene_root

			var mat := StandardMaterial3D.new()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

			var base_color = BLOCK_COLORS.get(block_type, Color.MAGENTA)
			if is_dock:
				base_color = Color.MAGENTA

			mat.albedo_color = base_color
			mm_instance.material_override = mat

			var mm := MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.instance_count = positions.size()

			if use_hexagons:
				var hex := CylinderMesh.new()
				hex.radial_segments = 6
				hex.top_radius = 1.0
				hex.bottom_radius = 1.0
				hex.height = 1.0
				mm.mesh = hex
			else:
				var box := BoxMesh.new()
				box.size = Vector3.ONE
				mm.mesh = box

			mm_instance.multimesh = mm

			for i in range(positions.size()):

				var local_pos: Vector3i = positions[i]

				var world_pos: Vector3

				if use_hexagons:
					world_pos = VoxelEngineHexagon.get_hex_world_position(
						Vector3i(
							anchor.x + local_pos.x,
							local_pos.y,
							anchor.y + local_pos.z
						),
						1.0,
						1.0
					)
				else:
					world_pos = Vector3(
						anchor.x + local_pos.x,
						local_pos.y,
						anchor.y + local_pos.z
					)

				mm.set_instance_transform(
					i,
					Transform3D(
						edge_alignment_basis if use_hexagons else Basis(),
						world_pos
					)
				)
func _clear_preview() -> void:
	var old = get_node_or_null("GeneratedIslands")
	if old: old.free()

func _print_zone_statistics(sorted_zones: Array[WorldZoneData]) -> void:
	print("\n" + "=".repeat(80))
	print("World Zone Statistics")
	print("=".repeat(80))
	
	for i in range(sorted_zones.size()):
		var zone: WorldZoneData = sorted_zones[i]
		var min_r = (sorted_zones[i-1].radius * 1.0) if i > 0 else 0.0
		var max_r = zone.radius * 1.0
		var islands = _island_blueprints.filter(func(b): return b.zone == zone)
		
		var block_counts: Dictionary = {}
		for island in islands:
			for pos in island.voxels:
				var type = island.voxels[pos]
				block_counts[type] = block_counts.get(type, 0) + 1
		
		var min_size_str = "(%d, %d, %d)" % [zone.min_island_size.x, zone.min_island_size.y, zone.min_island_size.z]
		var max_size_str = "(%d, %d, %d)" % [zone.max_island_size.x, zone.max_island_size.y, zone.max_island_size.z]
		
		print("Zone [%d]: %s" % [i, zone.display_name])
		print("  Radius: %.1f - %.1f | Docks: %d" % [min_r, max_r, zone.dock_count])
		print("  Island Dims: %s to %s" % [min_size_str, max_size_str])
		print("  Spacing: %s - %s" % [str(zone.min_island_spacing), str(zone.max_island_spacing)])
		print("  Density: %.2f | Size Weight: %.2f | Flatness: %.2f - %.2f" % [zone.island_density, zone.island_size_weight, zone.min_island_flatness, zone.max_island_flatness])
		print("  Coves: %d - %d | Cove Weight: %.2f - %.2f | Density: %.2f" % [zone.min_cove_count, zone.max_cove_count, zone.min_cove_weight, zone.max_cove_weight, zone.cove_density])
		print("  Generated: %d" % islands.size())
		
		# Block Rules
		print("  Block Rules:")
		if zone.block_spawn_rules.is_empty():
			print("    [None]")
		else:
			for rule in zone.block_spawn_rules:
				var type_name = Enums.BlockType.keys()[rule.block_type]
				print("    - Type: %s | Height: %d to %d" % [type_name, rule.min_height, rule.max_height])
				
		print("-".repeat(80))
		
		# Block Counts
		print("  Total Block Distribution:")
		var counts_str = PackedStringArray()
		for type_id in block_counts:
			var type_name = Enums.BlockType.keys()[type_id]
			counts_str.append("%s: %d" % [type_name, block_counts[type_id]])
		print("    " + ", ".join(counts_str))
		
		print("-".repeat(80))
	
	print("=".repeat(80))

func _pack_chunk(block_map: Dictionary) -> PackedInt32Array:
	var arr := PackedInt32Array()
	arr.resize(chunk_size * chunk_size * chunk_size)
	for pos in block_map:
		if pos.x >= 0 and pos.x < chunk_size and pos.y >= 0 and pos.y < chunk_size and pos.z >= 0 and pos.z < chunk_size:
			arr[pos.x + (pos.y * chunk_size) + (pos.z * chunk_size * chunk_size)] = block_map[pos]
	return arr
