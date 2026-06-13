class_name WorldZoneData
extends Resource

@export_category("Identity")
@export var display_name: String
@export_range(0, 2000, 1) var radius: int = 0
@export_range(1, 6, 1) var dock_count: int = 1

@export_category("Island Transform")
@export_range(4, 32, 1) var min_island_spacing
@export_range(4, 32, 1) var max_island_spacing
@export_range(0.0, 1.0, 0.01) var island_density: float = 0.5
@export var min_island_size: Vector3i = Vector3i.ZERO
@export var max_island_size: Vector3i = Vector3i.ZERO
@export_range(0.0, 1.0, 0.01) var island_size_weight: float = 0.5
@export_range(0.0, 1.0, 0.01) var min_island_flatness: float = 0.2
@export_range(0.0, 1.0, 0.01) var max_island_flatness: float = 0.2

@export_category("Island Coves")
@export_range(0, 6, 1) var min_cove_count: int = 0
@export_range(0, 6, 1) var max_cove_count: int = 2
@export_range(0.0, 1.0, 0.01) var min_cove_weight: float = 0.2
@export_range(0.0, 1.0, 0.01) var max_cove_weight: float = 0.2
@export_range(0.0, 1.0, 0.01) var cove_density: float = 0.5

@export_category("Block Types")
@export var block_spawn_rules: Array[VoxelBlueprintVoxelSpawnRule]

@export_category("Object Weights")
# TODO: Treasures
# TODO: Barrels
