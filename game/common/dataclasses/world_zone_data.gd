class_name WorldZoneData
extends Resource

@export var display_name: String
@export_range(0, 2000, 1) var radius: int = 0
@export var min_island_size: Vector3i
@export var max_island_size: Vector3i
@export_range(0.0, 1.0, 0.01) var min_island_flatness: float
@export_range(0.0, 1.0, 0.01) var max_island_flatness: float
@export_range(1, 6, 1) var dock_count: int = 1
# TODO: Block Type spawn weight
