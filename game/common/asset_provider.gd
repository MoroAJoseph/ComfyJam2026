class_name AssetService
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

static func get_block_item_scene() -> BlockItem:
	return AssetLoader.load_scene(
		Constants.Paths.Scenes.BLOCK_ITEM,
		BlockItem
	) as BlockItem

# ===
# Data 
# ===

# --- Save ---
static func get_new_settings_save_data() -> SettingsSaveData:
	return AssetLoader.load_resource(
		Constants.Paths.Data.NEW_SETTINGS_SAVE, 
		SettingsSaveData
	) as SettingsSaveData

static func get_new_game_save_data() -> GameSaveData:
	return AssetLoader.load_resource(
		Constants.Paths.Data.NEW_GAME_SAVE, 
		GameSaveData
	) as GameSaveData

static func get_settings_save_data() -> SettingsSaveData:
	return AssetLoader.load_resource(
		Constants.Paths.Data.USER_SETTINGS_SAVE, 
		SettingsSaveData
	) as SettingsSaveData

# --- Special Items ---
static func get_special_item_data(type: Enums.SpecialItemType) -> SpecialItemData:
	return AssetLoader.load_resource_from_table(
		type,
		Constants.Paths.Data.SPECIAL_ITEMS_TABLE,
		Enums.SpecialItemType.keys(),
		SpecialItemData
	) as SpecialItemData

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
