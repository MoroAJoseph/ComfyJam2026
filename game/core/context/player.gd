class_name PlayerContext
extends ContextData

enum Var { 
	# Inventory
	BLOCK_ITEMS,
	BLOCK_CAP,
	GOLD, 
	EQUIPPED_BOAT, 
	EQUIPPED_TOOL, 
	
	# Transform
	LOOK_DIR, 
	BOAT_DIR, 
	WORLD_LOC 
}

const DEFAULT: Dictionary[Var, Variant] = {
	# Inventory
	Var.BLOCK_ITEMS: [],
	Var.BLOCK_CAP: 0,
	Var.GOLD: 0,
	Var.EQUIPPED_BOAT: Enums.BoatType.NONE,
	Var.EQUIPPED_TOOL: Enums.ToolType.NONE,
	
	# Transform
	Var.LOOK_DIR: Vector3.ZERO,
	Var.BOAT_DIR: Vector3.ZERO,
	Var.WORLD_LOC: Vector3(0, 10, 0)
}

# ===
# Runtime
# ===

# --- Player Instance ---
signal player_insance_updated(value: Player)
var _player_instance: Player
var player_instance: Player:
	get: return _player_instance
	set(value):
		if _authorize_write():
			_player_instance = value
			player_insance_updated.emit(value)

# --- Boat Instance ---
signal boat_insance_updated(value: Boat)
var _boat_instance: Boat
var boat_instance: Boat:
	get: return _boat_instance
	set(value):
		if _authorize_write():
			_boat_instance = value
			boat_insance_updated.emit(value)

# ===
# Persistent
# ===

# --- Block Items ---
signal block_items_updated(value)
var _block_items: Array[BlockItemData]
var block_items: Array[BlockItemData]:
	get: return _block_items
	set(value): 
		if _authorize_write():
			_block_items = value
			block_items_updated.emit(value)

# --- Block Capacity ---
signal block_capacity_updated(value)
var _block_capacity: int
var block_capacity: int: 
	get: return _block_capacity
	set(value): 
		if _authorize_write():
			_block_capacity = value
			block_capacity_updated.emit(value)

# --- Gold ---
signal gold_updated(value)
var _gold: int
var gold: int: 
	get: return _gold
	set(value): 
		if _authorize_write():
			_gold = value
			gold_updated.emit(value)

# --- Boat ---
signal equipped_boat_updated(value)
var _equipped_boat: Enums.BoatType
var equipped_boat: Enums.BoatType: 
	get: return _equipped_boat
	set(value): 
		if _authorize_write():
			_equipped_boat = value
			equipped_boat_updated.emit(value)

# --- Tool ---
signal equipped_tool_updated(value)
var _equipped_tool: Enums.ToolType
var equipped_tool: Enums.ToolType: 
	get: return _equipped_tool
	set(value): 
		if _authorize_write():
			_equipped_tool = value
			equipped_tool_updated.emit(value)

# --- Look Direction ---
signal look_direction_updated(value: Vector3)
var _look_direction: Vector3
var look_direction: Vector3:
	get: return _look_direction
	set(value):
		if _authorize_write():
			_look_direction = value
			look_direction_updated.emit(value)

# --- Boat Direction ---
signal boat_direction_updated(value: Vector3)
var _boat_direction: Vector3
var boat_direction: Vector3:
	get: return _boat_direction
	set(value):
		if _authorize_write():
			_boat_direction = value
			boat_direction_updated.emit(value)

# --- World Location ---
signal world_location_updated(value: Vector3)
var _world_location: Vector3
var world_location: Vector3:
	get: return _world_location
	set(value):
		if _authorize_write():
			_world_location = value
			world_location_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	# Instances
	_player_instance = null
	_boat_instance = null
	
	# Inventory
	_gold = DEFAULT[Var.GOLD]
	_block_items = DEFAULT[Var.BLOCK_ITEMS]
	_block_capacity = DEFAULT[Var.BLOCK_CAP]
	_equipped_boat = DEFAULT[Var.EQUIPPED_BOAT] as Enums.BoatType
	_equipped_tool = DEFAULT[Var.EQUIPPED_TOOL] as Enums.ToolType
	
	# Transform
	_look_direction = DEFAULT[Var.LOOK_DIR]
	_boat_direction = DEFAULT[Var.BOAT_DIR]
	_world_location = DEFAULT[Var.WORLD_LOC]
