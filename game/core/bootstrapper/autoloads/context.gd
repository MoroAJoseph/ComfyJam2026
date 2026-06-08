extends Node

'''
Singleton context for global systems
'''

# CRITICAL TODO: Ensure we clear context when leaving the world/game

var session: SessionContext
var progression: ProgressionContext
var ui: UIContext
var world: WorldContext
var player: PlayerContext

# ===
# Built-In
# ===

func _ready() -> void:
	session = SessionContext.new()
	progression = ProgressionContext.new()
	progression.gold = 10000
	ui = UIContext.new()
	world = WorldContext.new()
	player = PlayerContext.new()

# ===
# Public
# ===

func get_save_data() -> SaveData:
	var data := SaveData.new()
	
	# Progression
	data.current_equipped_boat = progression.equipped_boat_type
	data.current_gold = progression.gold
	
	# Player
	data.player_world_location = player.world_location
	data.player_boat_direction = player.boat_direction
	data.player_look_direction = player.look_direction
	
	# World
	data.world_time = world.time
	data.world_sea_time = world.sea_time

	return data

func set_from_save(_data: SaveData) -> void:
	# reverse logic from get save data
	# setting everything from the data
	pass
