class_name VoxelEngineBlueprintSpawnRule
extends Resource

@export var block_type: int
@export var min_height: int = 0
@export var max_height: int = 255
@export_range(0.0, 1.0) var density: float = 1.0
