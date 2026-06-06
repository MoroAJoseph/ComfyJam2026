class_name SaveData
extends Resource

@export_category("Progression")
@export var current_equipped_boat: BoatData.Type

@export_category("Player")
@export var player_world_location: Vector3
@export var player_boat_direction: Vector3
@export var player_look_direction: Vector3

@export_category("World")
@export var world_time: float
@export var world_sea_time: float

func collect() -> void:
	if not Context: return
	
	# Progression
	var progression: = Context.progression
	current_equipped_boat = progression.equipped_boat_type
	
	# Player
	var player: = Context.player
	player_world_location = player.world_location
	player_boat_direction = player.boat_direction
	player_look_direction = player.look_direction
	
	# World
	var world: = Context.world
	world_time = world.time
	world_sea_time = world.sea_time

