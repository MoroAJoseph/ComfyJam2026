class_name AssetProvider
extends RefCounted

# ===
# Scenes
# ===

static func get_bootsplash_scene() -> Bootsplash:
	return AssetLoader.load_scene(
		Constants.Paths.Scenes.BOOTSPLASH, 
		Bootsplash
	) as Bootsplash

static func get_game_scene() -> Game:
	return AssetLoader.load_scene(
		Constants.Paths.Scenes.GAME, 
		Game
	) as Game

static func get_title_scene() -> Title:
	return AssetLoader.load_scene(
		Constants.Paths.Scenes.TITLE, 
		Title
	) as Title

static func get_world_scene() -> World:
	return AssetLoader.load_scene(
		Constants.Paths.Scenes.WORLD, 
		World
	) as World

static func get_player_scene() -> Player:
	return AssetLoader.load_scene(
		Constants.Paths.Scenes.PLAYER, 
		Player
	) as Player

# ===
# Data 
# ===

# --- Save ---
static func get_save_data(is_new_game: bool) -> SaveData:
	var path := Constants.Paths.Data.NEW_GAME_SAVE if is_new_game else Constants.Paths.Data.USER_SAVE
	return AssetLoader.load_resource(
		path, 
		SaveData
	) as SaveData

# --- Boats ---
static func get_boat_scene(type: Enums.BoatType) -> Boat:
	return AssetLoader.load_scene_from_table(
		type, 
		Constants.Paths.Scenes.BOATS_TABLE, 
		Enums.BoatType.keys(), 
		Boat
	) as Boat

static func get_boat_data(type: Enums.BoatType) -> BoatData:
	return AssetLoader.load_resource_from_table(
		type, 
		Constants.Paths.Data.BOATS_TABLE, 
		Enums.BoatType.keys(), 
		BoatData
	) as BoatData

# --- Tools ---
static func get_tool_data(type: Enums.ToolType) -> ToolData:
	return AssetLoader.load_resource_from_table(
		type, 
		Constants.Paths.Data.TOOLS_TABLE, 
		Enums.ToolType.keys(), 
		ToolData
	) as ToolData

# --- Blocks ---
static func get_block_data(type: Enums.BlockType) -> BlockData:
	return AssetLoader.load_resource_from_table(
		type, 
		Constants.Paths.Data.BLOCKS_TABLE, 
		Enums.BlockType.keys(), 
		BlockData
	) as BlockData

# --- Docks ---


# --- Chest ---
static func get_chest_data(type: Enums.ChestType) -> ChestData:
	return AssetLoader.load_resource_from_table(
		type, 
		Constants.Paths.Data.CHESTS_TABLE, 
		Enums.ChestType.keys(), 
		ChestData
	) as ChestData

	
# --- Barrels ---
static func get_barrel_data(type: Enums.BarrelType) -> BarrelData:
	return AssetLoader.load_resource_from_table(
		type, 
		Constants.Paths.Data.BARRELS_TABLE, 
		Enums.BarrelType.keys(), 
		BarrelData
	) as BarrelData

# --- Crates ---


# --- Bottles ---
