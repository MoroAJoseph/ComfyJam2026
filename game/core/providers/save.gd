class_name SaveProvider
extends ContextProvider

var progression_context: ProgressionContext
var player_context: PlayerContext
var world_context: WorldContext

# ===
# Private
# ===

func _init(
	p_progression: ProgressionContext, 
	p_player: PlayerContext, 
	p_world: WorldContext
) -> void:
	progression_context = p_progression
	player_context = p_player
	world_context = p_world

# ===
# Public
# ===

func save_game() -> void:
	var save_resource := SaveData.new()
	
	# Progression
	save_resource.chest_queue = progression_context.chest_queue
	
	# Player
	save_resource.player_boat = player_context.equipped_boat
	save_resource.player_tool = player_context.equipped_tool
	save_resource.player_gold = player_context.gold
	save_resource.player_world_location = player_context.world_location
	save_resource.player_boat_direction = player_context.boat_direction
	save_resource.player_look_direction = player_context.look_direction
	
	# World
	save_resource.world_seed = world_context.noise_seed
	save_resource.world_time = world_context.time
	
	var error := ResourceSaver.save(save_resource, Constants.Paths.Data.USER_SAVE)
	if error != OK:
		push_error("SaveProvider: Failed to save. Error code: %d" % error)

func load_game(is_new_game: bool) -> bool:
	var path: String = Constants.Paths.Data.NEW_GAME_SAVE if is_new_game else Constants.Paths.Data.USER_SAVE
	var save_resource := AssetLoader.load_resource(path, SaveData) as SaveData
	if not save_resource: 
		print_debug("no save file")
		return false
		
	# Progression
	progression_context.chest_queue = save_resource.chest_queue
	
	# Player
	player_context.equipped_boat = save_resource.player_boat
	player_context.equipped_tool = save_resource.player_tool
	player_context.gold = save_resource.player_gold
	player_context.world_location = save_resource.player_world_location
	player_context.boat_direction = save_resource.player_boat_direction
	player_context.look_direction = save_resource.player_look_direction
	
	# World
	world_context.noise_seed = save_resource.world_seed
	world_context.time = save_resource.world_time
	
	return true
