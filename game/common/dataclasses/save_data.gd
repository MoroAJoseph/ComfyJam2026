class_name SaveData
extends Resource

@export_category("Progression")
@export var current_equipped_boat: Enums.BoatType
@export var current_equipped_tool: Enums.ToolType
@export var current_gold: int

@export_category("Player")
@export var player_world_location: Vector3
@export var player_boat_direction: Vector3
@export var player_look_direction: Vector3

@export_category("World")
@export var world_seed: int
@export var world_block_diff: Dictionary[Vector3, int] # block data type
@export var world_time: float
@export var world_sea_time: float

# - things to add:
# player inventory
# dock inventories
