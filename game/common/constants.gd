class_name Constants
extends RefCounted

const NEW_GAME_SAVE_DATA_PATH := "res://common/data/new_game_save_data.tres"
const USER_SAVE_PATH := "user://savegame.tres"


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
		BoatData.Type.RAFT: BoatData.new(BoatData.Type.RAFT, 20.0, 8.0, 3.0, 0.2, 0.5, 2.0, 100)
	}
	
	static func get_boat_data(type: BoatData.Type) -> BoatData:
		return BOAT_DATA.get(type, null)
	
	static var BOAT_SCENE_PATH: Dictionary[BoatData.Type, String] = {
		BoatData.Type.RAFT: "res://core/base_classes/buoyant/boat/boat.tscn"
	}
	
	static func get_boat_scene_path(type: BoatData.Type) -> String:
		return BOAT_SCENE_PATH.get(type, null)
