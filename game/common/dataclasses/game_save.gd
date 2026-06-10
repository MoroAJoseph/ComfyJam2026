class_name GameSaveData
extends Resource

@export_category("Progression")
@export var chest_queue: Array[Enums.ChestType] = []

@export_category("Player")
@export var player_boat: Enums.BoatType
@export var player_tool: Enums.ToolType
@export var player_gold: int
@export var player_world_location: Vector3
@export var player_boat_direction: Vector3
@export var player_look_direction: Vector3

@export_category("World")
@export var world_seed: int
@export var world_block_diff: Dictionary[Vector3i, Enums.BlockType]
@export var world_time: float
@export var world_sea_time: float
