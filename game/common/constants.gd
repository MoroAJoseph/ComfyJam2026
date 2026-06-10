class_name Constants
extends RefCounted

class Paths:
	
	class Scenes:
		
		const CORE_DIR := "res://core/scenes/"
		const FEATURES_DIR := "res://features/"
		
		# --- Core ---
		const BOOTSPLASH := CORE_DIR + "bootsplash/bootsplash.tscn"
		const GAME := CORE_DIR + "game/game.tscn"
		const TITLE := CORE_DIR + "title/title.tscn"
		const WORLD := CORE_DIR + "world/world.tscn"
		const PLAYER := CORE_DIR + "player/player.tscn"
		
		const BLOCK_ITEM := FEATURES_DIR + "blocks/item/block_item.tscn"
		
		# --- Boats ---
		const BOATS_DIR := FEATURES_DIR + "equipment/boats/"
		const BOATS_TABLE: Dictionary[Enums.BoatType, String] = {
			Enums.BoatType.RAFT: BOATS_DIR + "raft/raft.tscn",
			Enums.BoatType.ROW_SMALL: BOATS_DIR + "row_boat_small/row_boat_small.tscn",
			Enums.BoatType.SHIP_SMALL: BOATS_DIR + "ship_small/ship_small.tscn",
			Enums.BoatType.SHIP_MEDIUM_2: BOATS_DIR + "ship_medium_2/ship_medium_2.tscn",
		}
	
	class Data:
		
		const BASE_DIR := "res://assets/data/"
		
		# --- Saves ---
		const SAVES_DIR := BASE_DIR + "saves/"
		const NEW_GAME_SAVE := SAVES_DIR + "new_game.tres"
		const NEW_SETTINGS_SAVE := SAVES_DIR + "new_settings.tres"
		const USER_SAVES_DIR := "user://saves/"
		const USER_GAME_SAVES_DIR := USER_SAVES_DIR + "games/"
		const USER_GAME_AUTOSAVES_DIR := USER_SAVES_DIR + "games/autosave/"
		const USER_SETTINGS_SAVE := USER_SAVES_DIR + "settings.tres"
		
		# --- Boats ---
		const BOATS_DIR := BASE_DIR + "boats/"
		const BOATS_TABLE: Dictionary[Enums.BoatType, String] = {
			Enums.BoatType.RAFT: BOATS_DIR + "raft.tres",
			Enums.BoatType.ROW_SMALL: BOATS_DIR + "row_small.tres",
			Enums.BoatType.SHIP_SMALL: BOATS_DIR + "ship_small.tres",
			Enums.BoatType.SHIP_MEDIUM_2: BOATS_DIR + "ship_medium.tres",
		}

		# --- Tools ---
		const TOOLS_DIR := BASE_DIR + "tools/"
		const TOOLS_TABLE: Dictionary[Enums.ToolType, String] = {}

		# --- Blocks ---
		const BLOCKS_DIR := BASE_DIR + "blocks/"
		const BLOCKS_TABLE: Dictionary[Enums.BlockType, String] = {}
		
		# --- Barrels ---
		const BARRELS_DIR := BASE_DIR + "barrels/"
		const BARRELS_TABLE: Dictionary[Enums.BarrelType, String] = {}
		
		# --- Chests ---
		const CHESTS_DIR := BASE_DIR + "chests/"
		const CHESTS_TABLE: Dictionary[Enums.ChestType, String] = {}
		
		# --- Crates ---
		const CRATES_DIR := BASE_DIR + "crates/"
		const CRATES_TABLE: Dictionary[Enums.ChestType, String] = {}
		
		# --- Bottle Messages ---
		const BOTTLES := BASE_DIR + "bottles/"
		const BOTTLE_DIR: Dictionary[Enums.ChestType, String] = {}
		
	class Textures:
		
		const BASE_DIR := "res://assets/textures/"
		
		# --- Blocks ---
		const BLOCKS_DIR := BASE_DIR + "blocks/"
		const BLOCKS_TABLE: Dictionary[Enums.BlockType, String] = {
			
		}

const MOUSE_INPUT_COEFFICIENT := 0.005
const AUDIO_VOLUME_COEFFICIENT := 1.0
const MIN_RENDER_DISTANCE := 8
const MAX_RENDER_DISTANCE := 32

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
	const LAND_INDEX := 1
	const WATER_INDEX := 2
	const PLAYER_INDEX := 3
	const HOVER_INDEX := 4
	const ITEM_INDEX := 5
	const TREASURE_INDEX := 6
	const BARREL_INDEX := 7
	
	# Mask
	const LAND_MASK := 1 << 0
	const WATER_MASK := 1 << 1
	const PLAYER_MASK := 1 << 2
	const HOVER_MASK := 1 << 3
	const ITEM_MASK := 1 << 4
	const TREASURE_MASK := 1 << 5
	const BARREL_MASK := 1 << 6
