class_name Constants
extends RefCounted

class Paths:
	
	const NEW_GAME_SAVE_DATA := "res://common/data/new_game_save_data.tres"
	const USER_SAVE := "user://savegame.tres"
	const WORLD_SCENE := "res://core/world/world.tscn"
	const PLAYER_SCENE := "res://core/player/player.tscn"
	
	static var BOAT_SCENE: Dictionary[Enums.BoatType, String] = {
		Enums.BoatType.ROW_SMALL: "res://features/boats/row_boat_small/row_boat_small.tscn",
		Enums.BoatType.SHIP_SMALL: "res://features/boats/ship_small/ship_small.tscn",
		Enums.BoatType.SHIP_MEDIUM_2: "res://features/boats/ship_medium_2/ship_medium_2.tscn",
	}
	
	static func get_boat_scene(type: Enums.BoatType) -> String: return BOAT_SCENE.get(type, "")

class PhysicsLayer:
	
	# Index
	const LAND_INDEX := 1
	const WATER_INDEX := 2
	const PLAYER_INDEX := 3
	const HOVER_INDEX := 4
	const ITEM_INDEX := 5
	const TREASURE_INDEX := 6
	
	# Mask
	const LAND_MASK := 1 << 0
	const WATER_MASK := 1 << 1
	const PLAYER_MASK := 1 << 2
	const HOVER_MASK := 1 << 3
	const ITEM_MASK := 1 << 4
	const TREASURE_MASK := 1 << 5

class LUT:

	# --- Chests ---
	static var CHEST_DATA: Dictionary[Enums.ChestType, ChestData] = {
		# Wood
		Enums.ChestType.WOOD: ChestData.new(
			Enums.ChestType.WOOD, 
			Color(0.45, 0.24, 0.1), 
			{
				Enums.RarityType.COMMON: 0.4, 
				Enums.RarityType.RARE: 0.4, 
				Enums.RarityType.EPIC: 0.15, 
				Enums.RarityType.LEGENDARY: 0.05
			}
		),
		# Iron
		Enums.ChestType.IRON: ChestData.new(
			Enums.ChestType.IRON, 
			Color(0.5, 0.5, 0.5), 
			{
				Enums.RarityType.COMMON: 0.4, 
				Enums.RarityType.RARE: 0.4, 
				Enums.RarityType.EPIC: 0.15, 
				Enums.RarityType.LEGENDARY: 0.05
			}
		),
		# Gold
		Enums.ChestType.GOLD: ChestData.new(
			Enums.ChestType.GOLD, 
			Color(1.0, 0.8, 0.2), 
			{
				Enums.RarityType.COMMON: 0.1, 
				Enums.RarityType.RARE: 0.3, 
				Enums.RarityType.EPIC: 0.4, 
				Enums.RarityType.LEGENDARY: 0.2
			}
		),
		# Chest
		Enums.ChestType.MYSTIC: ChestData.new(
			Enums.ChestType.MYSTIC, 
			Color(0.6, 0.2, 1.0), 
			{
				Enums.RarityType.COMMON: 0.0, 
				Enums.RarityType.RARE: 0.1, 
				Enums.RarityType.EPIC: 0.4, 
				Enums.RarityType.LEGENDARY: 0.5
			}
		)
	}
	static func get_chest_data(type: Enums.ChestType) -> ChestData: return CHEST_DATA.get(type, null)
	
	# --- Chest Rewards ---
	static var CHEST_REWARD_DATA: Dictionary[Enums.RarityType, ChestRewardData] = {
		# Common
		Enums.RarityType.COMMON: ChestRewardData.new(
			Enums.RarityType.COMMON, 
			50, 
			150, 
			Color(0.7, 0.7, 0.7)
		),
		# Rare
		Enums.RarityType.RARE: ChestRewardData.new(
			Enums.RarityType.RARE, 
			200, 
			500, 
			Color(0.2, 0.4, 1.0)
		),
		# Epic
		Enums.RarityType.EPIC: ChestRewardData.new(
			Enums.RarityType.EPIC, 
			750, 
			1500, 
			Color(0.6, 0.2, 1.0)
		),
		# Legendary
		Enums.RarityType.LEGENDARY: ChestRewardData.new(
			Enums.RarityType.LEGENDARY, 
			2500, 
			5000, 
			Color(1.0, 0.8, 0.2)
		)
	}

	static func get_chest_reward_data(rarity: Enums.RarityType) -> ChestRewardData: return CHEST_REWARD_DATA.get(rarity, null)
	
	# --- Boats ---
	static var BOAT_DATA: Dictionary[Enums.BoatType, BoatData] = {
		# Row Small
		Enums.BoatType.ROW_SMALL: BoatData.new(
			Enums.BoatType.ROW_SMALL, 
			20.0, 
			8.0, 
			3.0, 
			0.2, 
			0.5, 
			2.0, 
			100, 
			12, 
			6, 
			2
		),
		# Ship Small
		Enums.BoatType.SHIP_SMALL: BoatData.new(
			Enums.BoatType.SHIP_SMALL, 
			20.0, 
			30.0, 
			3.0, 
			0.2, 
			0.5, 
			2.0, 
			100, 
			24, 
			12, 
			2
		),
		# Ship Medium
		Enums.BoatType.SHIP_MEDIUM_2: BoatData.new(
			Enums.BoatType.SHIP_MEDIUM_2, 
			35.0, 
			35.0, 
			2.5, 
			0.15, 
			0.4, 
			1.5, 
			1000, 
			25, 
			12, 
			4
		)
	}
	
	static func get_boat_data(type: Enums.BoatType) -> BoatData: return BOAT_DATA.get(type, null)

	# --- Blocks ---

	# --- Docks ---
