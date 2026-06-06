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
	}
	
	static func get_boat_scene(type: BoatData.Type) -> String:
		return BOAT_SCENE.get(type, null)

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

	# --- Boats ---
	static var BOAT_DATA: Dictionary[BoatData.Type, BoatData] = {
		BoatData.Type.ROW_SMALL: BoatData.new(
			BoatData.Type.ROW_SMALL, 20.0, 8.0, 3.0, 0.2, 0.5, 2.0, 100, 12, 6, 2
		),
		BoatData.Type.SHIP_SMALL: BoatData.new(
			BoatData.Type.SHIP_SMALL, 20.0, 30.0, 3.0, 0.2, 0.5, 2.0, 100, 24, 12, 2
		)
	}
	
	static func get_boat_data(type: BoatData.Type) -> BoatData:
		return BOAT_DATA.get(type, null)

	# --- Blocks ---

	# --- Docks ---
