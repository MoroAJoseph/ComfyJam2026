class_name Constants
extends RefCounted

class Paths:
	
	class Scenes:
		
		const CORE_DIR: String = "res://core/scenes/"
		const FEATURES_DIR: String = "res://features/"
		
		# --- Core ---
		const BOOTSPLASH: String = CORE_DIR + "bootsplash/bootsplash.tscn"
		const GAME: String = CORE_DIR + "game/game.tscn"
		const TITLE: String = CORE_DIR + "title/title.tscn"
		const WORLD: String = CORE_DIR + "world/world.tscn"
		const PLAYER: String = CORE_DIR + "player/player.tscn"
		
		const BLOCK_ITEM: String = FEATURES_DIR + "blocks/item/block_item.tscn"
		
		# --- Boats ---
		const BOATS_DIR: String = FEATURES_DIR + "equipment/boats/"
		const BOATS_TABLE: Dictionary[Enums.BoatType, String] = {
			Enums.BoatType.RAFT: BOATS_DIR + "raft/raft.tscn",
			Enums.BoatType.ROW_SMALL: BOATS_DIR + "row_boat_small/row_boat_small.tscn",
			Enums.BoatType.SHIP_SMALL: BOATS_DIR + "ship_small/ship_small.tscn",
			Enums.BoatType.SHIP_MEDIUM_2: BOATS_DIR + "ship_medium_2/ship_medium_2.tscn",
		}
	
	class Data:
		
		const BASE_DIR: String = "res://assets/data/"
		
		# --- Saves ---
		const SAVES_DIR: String = BASE_DIR + "saves/"
		const NEW_GAME_SAVE: String = SAVES_DIR + "new_game.tres"
		const NEW_SETTINGS_SAVE: String = SAVES_DIR + "new_settings.tres"
		const USER_SAVES_DIR: String = "user://saves/"
		const USER_GAME_SAVES_DIR: String = USER_SAVES_DIR + "games/"
		const USER_GAME_AUTOSAVES_DIR: String = USER_SAVES_DIR + "games/autosave/"
		const USER_SETTINGS_SAVE: String = USER_SAVES_DIR + "settings.tres"
		
		# --- Special Items ---
		const SPECIAL_ITEMS_DIR: String = BASE_DIR + "special_items/"
		const SPECIAL_ITEMS_TABLE: Dictionary[Enums.SpecialItemType, String] = {
			Enums.SpecialItemType.REPAIR_KIT: SPECIAL_ITEMS_DIR + "repair_kit.tres",
			Enums.SpecialItemType.TIME_SKIP_1: SPECIAL_ITEMS_DIR + "time_skip_1.tres",
			Enums.SpecialItemType.TIME_SKIP_2: SPECIAL_ITEMS_DIR + "time_skip_2.tres",
			Enums.SpecialItemType.TIME_SKIP_3: SPECIAL_ITEMS_DIR + "time_skip_3.tres",
		}
		
		# --- Boats ---
		const BOATS_DIR: String = BASE_DIR + "boats/"
		const BOATS_TABLE: Dictionary[Enums.BoatType, String] = {
			Enums.BoatType.RAFT: BOATS_DIR + "raft.tres",
			Enums.BoatType.ROW_SMALL: BOATS_DIR + "row_small.tres",
			Enums.BoatType.SHIP_SMALL: BOATS_DIR + "ship_small.tres",
			Enums.BoatType.SHIP_MEDIUM_2: BOATS_DIR + "ship_medium.tres",
		}

		# --- Tools ---
		const TOOLS_DIR: String = BASE_DIR + "tools/"
		const TOOLS_TABLE: Dictionary[Enums.ToolType, String] = {}

		# --- Blocks ---
		const BLOCKS_DIR: String = BASE_DIR + "blocks/"
		const BLOCKS_TABLE: Dictionary[Enums.BlockType, String] = {}
		
		# --- Barrels ---
		const BARRELS_DIR: String = BASE_DIR + "barrels/"
		const BARRELS_TABLE: Dictionary[Enums.BarrelType, String] = {}
		
		# --- Chests ---
		const CHESTS_DIR: String = BASE_DIR + "chests/"
		const CHESTS_TABLE: Dictionary[Enums.ChestType, String] = {}
		
		# --- Crates ---
		const CRATES_DIR: String = BASE_DIR + "crates/"
		const CRATES_TABLE: Dictionary[Enums.ChestType, String] = {}
		
		# --- Bottle Messages ---
		const BOTTLES: String = BASE_DIR + "bottles/"
		const BOTTLE_DIR: Dictionary[Enums.ChestType, String] = {}
		
	class Textures:
		
		const BASE_DIR: String = "res://assets/textures/"
		
		# --- Blocks ---
		const BLOCKS_DIR: String = BASE_DIR + "blocks/"
		const BLOCKS_TABLE: Dictionary[Enums.BlockType, String] = {
			
		}

const MOUSE_INPUT_COEFFICIENT: float = 0.005
const AUDIO_VOLUME_COEFFICIENT: float= 1.0
const MIN_RENDER_DISTANCE: int = 8
const MAX_RENDER_DISTANCE: int = 32

# [ChestType, RarityType] : [MinGold, MaxGold]
const CHEST_REWARD_MATRIX: Dictionary[Vector2i, Vector2i] = {
	# Wood
	Vector2i(Enums.ChestType.WOOD, Enums.RarityType.COMMON):    Vector2i(10, 20),
	Vector2i(Enums.ChestType.WOOD, Enums.RarityType.RARE):      Vector2i(25, 40),
	Vector2i(Enums.ChestType.WOOD, Enums.RarityType.EPIC):      Vector2i(60, 100),
	Vector2i(Enums.ChestType.WOOD, Enums.RarityType.LEGENDARY): Vector2i(200, 300),
	
	# Iron
	Vector2i(Enums.ChestType.IRON, Enums.RarityType.COMMON):    Vector2i(20, 35),
	Vector2i(Enums.ChestType.IRON, Enums.RarityType.RARE):      Vector2i(50, 70),
	Vector2i(Enums.ChestType.IRON, Enums.RarityType.EPIC):      Vector2i(120, 180),
	Vector2i(Enums.ChestType.IRON, Enums.RarityType.LEGENDARY): Vector2i(400, 600),
	
	# Gold
	Vector2i(Enums.ChestType.GOLD, Enums.RarityType.COMMON):    Vector2i(40, 60),
	Vector2i(Enums.ChestType.GOLD, Enums.RarityType.RARE):      Vector2i(100, 140),
	Vector2i(Enums.ChestType.GOLD, Enums.RarityType.EPIC):      Vector2i(250, 350),
	Vector2i(Enums.ChestType.GOLD, Enums.RarityType.LEGENDARY): Vector2i(800, 1200),
	
	# Mystic
	Vector2i(Enums.ChestType.MYSTIC, Enums.RarityType.COMMON):    Vector2i(80, 120),
	Vector2i(Enums.ChestType.MYSTIC, Enums.RarityType.RARE):      Vector2i(200, 280),
	Vector2i(Enums.ChestType.MYSTIC, Enums.RarityType.EPIC):      Vector2i(500, 700),
	Vector2i(Enums.ChestType.MYSTIC, Enums.RarityType.LEGENDARY): Vector2i(2000, 3000)
}

class PhysicsLayer:
	
	# Index
	const LAND_INDEX: int = 1
	const WATER_INDEX: int = 2
	const PLAYER_INDEX: int = 3
	const HOVER_INDEX: int = 4
	const ITEM_INDEX: int = 5
	const TREASURE_INDEX: int = 6
	const BARREL_INDEX: int = 7
	
	# Mask
	const LAND_MASK: int = 1 << 0
	const WATER_MASK: int = 1 << 1
	const PLAYER_MASK: int = 1 << 2
	const HOVER_MASK: int = 1 << 3
	const ITEM_MASK: int = 1 << 4
	const TREASURE_MASK: int = 1 << 5
	const BARREL_MASK: int = 1 << 6
