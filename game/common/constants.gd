class_name Constants
extends RefCounted

class Paths:
	
	const NEW_GAME_SAVE_DATA := "res://common/data/new_game_save_data.tres"
	const USER_SAVE := "user://savegame.tres"
	const WORLD_SCENE := "res://core/world/world.tscn"
	const PLAYER_SCENE := "res://core/player/player.tscn"
	
	static var BOAT_SCENE: Dictionary[BoatData.Type, String] = {
		BoatData.Type.ROW_SMALL: "res://features/boats/row_boat_small/row_boat_small.tscn",
		BoatData.Type.SHIP_SMALL: "res://features/boats/ship_small/ship_small.tscn",
		BoatData.Type.SHIP_MEDIUM_2: "res://features/boats/ship_medium_2/ship_medium_2.tscn",
	}
	
	static func get_boat_scene(type: BoatData.Type) -> String:
		return BOAT_SCENE.get(type, "")

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

	enum Rarity {
		COMMON,
		RARE,
		EPIC,
		LEGENDARY
	}

	enum ChestType {
		WOOD,
		IRON,
		GOLD,
		MYSTIC
	}

	class RewardData:
		var rarity: Rarity
		var min_gold: int
		var max_gold: int
		var color: Color
		var name: String

		func _init(p_rarity: Rarity, p_min: int, p_max: int, p_color: Color, p_name: String):
			rarity = p_rarity
			min_gold = p_min
			max_gold = p_max
			color = p_color
			name = p_name

	static var REWARD_DATA: Dictionary[Rarity, RewardData] = {
		Rarity.COMMON: RewardData.new(Rarity.COMMON, 50, 150, Color(0.7, 0.7, 0.7), "Common"),
		Rarity.RARE: RewardData.new(Rarity.RARE, 200, 500, Color(0.2, 0.4, 1.0), "Rare"),
		Rarity.EPIC: RewardData.new(Rarity.EPIC, 750, 1500, Color(0.6, 0.2, 1.0), "Epic"),
		Rarity.LEGENDARY: RewardData.new(Rarity.LEGENDARY, 2500, 5000, Color(1.0, 0.8, 0.2), "Legendary")
	}

	class ChestData:
		var type: ChestType
		var color: Color
		var name: String
		var loot_table: Dictionary # Rarity -> probability

		func _init(p_type: ChestType, p_color: Color, p_name: String, p_loot: Dictionary):
			type = p_type
			color = p_color
			name = p_name
			loot_table = p_loot

	static var CHEST_DATA: Dictionary[ChestType, ChestData] = {
		ChestType.WOOD: ChestData.new(ChestType.WOOD, Color(0.45, 0.24, 0.1), "Wood Chest", {
			Rarity.COMMON: 0.8, Rarity.RARE: 0.15, Rarity.EPIC: 0.04, Rarity.LEGENDARY: 0.01
		}),
		ChestType.IRON: ChestData.new(ChestType.IRON, Color(0.5, 0.5, 0.5), "Iron Chest", {
			Rarity.COMMON: 0.4, Rarity.RARE: 0.4, Rarity.EPIC: 0.15, Rarity.LEGENDARY: 0.05
		}),
		ChestType.GOLD: ChestData.new(ChestType.GOLD, Color(1.0, 0.8, 0.2), "Gold Chest", {
			Rarity.COMMON: 0.1, Rarity.RARE: 0.3, Rarity.EPIC: 0.4, Rarity.LEGENDARY: 0.2
		}),
		ChestType.MYSTIC: ChestData.new(ChestType.MYSTIC, Color(0.6, 0.2, 1.0), "Mystic Chest", {
			Rarity.COMMON: 0.0, Rarity.RARE: 0.1, Rarity.EPIC: 0.4, Rarity.LEGENDARY: 0.5
		})
	}

	static func get_random_chest_reward(type: ChestType = ChestType.WOOD) -> Dictionary:
		var roll = randf()
		var cumulative_prob = 0.0
		
		var data = CHEST_DATA[type]
		var table = data.loot_table
		
		for rarity in [Rarity.COMMON, Rarity.RARE, Rarity.EPIC, Rarity.LEGENDARY]:
			cumulative_prob += table[rarity]
			if roll <= cumulative_prob:
				var reward = REWARD_DATA[rarity]
				var gold = randi_range(reward.min_gold, reward.max_gold)
				return {
					"rarity": rarity,
					"name": reward.name,
					"gold": gold,
					"color": reward.color
				}
		
		# Fallback
		var fallback = REWARD_DATA[Rarity.COMMON]
		return {
			"rarity": Rarity.COMMON,
			"name": fallback.name,
			"gold": fallback.min_gold,
			"color": fallback.color
		}

	# --- Boats ---
	static var BOAT_DATA: Dictionary[BoatData.Type, BoatData] = {
		BoatData.Type.ROW_SMALL: BoatData.new(
			BoatData.Type.ROW_SMALL, 20.0, 8.0, 3.0, 0.2, 0.5, 2.0, 100, 12, 6, 2
		),
		BoatData.Type.SHIP_SMALL: BoatData.new(
			BoatData.Type.SHIP_SMALL, 20.0, 30.0, 3.0, 0.2, 0.5, 2.0, 100, 24, 12, 2
		),
		BoatData.Type.SHIP_MEDIUM_2: BoatData.new(
			BoatData.Type.SHIP_MEDIUM_2, 35.0, 35.0, 2.5, 0.15, 0.4, 1.5, 1000, 25, 12, 4
		)
	}
	
	static func get_boat_data(type: BoatData.Type) -> BoatData:
		return BOAT_DATA.get(type, null)

	# --- Blocks ---

	# --- Docks ---
