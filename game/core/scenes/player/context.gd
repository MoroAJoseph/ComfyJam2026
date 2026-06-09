class_name PlayerContext
extends ContextData

enum Var { 
	GOLD, 
	EQUIPPED_BOAT, 
	EQUIPPED_TOOL, 
	LOOK_DIR, 
	BOAT_DIR, 
	WORLD_LOC 
}

const DEFAULT: Dictionary[Var, Variant] = {
	Var.GOLD: 0,
	Var.EQUIPPED_BOAT: Enums.BoatType.NONE,
	Var.EQUIPPED_TOOL: Enums.ToolType.NONE,
	Var.LOOK_DIR: Vector3.ZERO,
	Var.BOAT_DIR: Vector3.ZERO,
	Var.WORLD_LOC: Vector3(0, 10, 0)
}

# ===
# Runtime
# ===

# --- Player ---
signal player_insance_updated(value: Player)
var player_instance: Player:
	set(value):
		player_instance = value
		player_insance_updated.emit(value)

# --- Boat ---
signal boat_insance_updated(value: Boat)
var boat_instance: Boat:
	set(value):
		boat_instance = value
		boat_insance_updated.emit(value)

# ===
# Persistent
# ===

# --- Gold ---
signal gold_updated(value)
var gold: int: 
	set(value): 
		gold = value
		gold_updated.emit(value)

# --- Boat ---
signal equipped_boat_updated(value)
var equipped_boat: Enums.BoatType: 
	set(value): 
		equipped_boat = value
		equipped_boat_updated.emit(value)

# --- Tool ---
signal equipped_tool_updated(value)
var equipped_tool: Enums.ToolType: 
	set(value): 
		equipped_tool = value
		equipped_tool_updated.emit(value)

# --- Look Direction ---
signal look_direction_updated(value: Vector3)
var look_direction: Vector3:
	set(value):
		look_direction = value
		look_direction_updated.emit(value)

# --- Boat Direction ---
signal boat_direction_updated(value: Vector3)
var boat_direction: Vector3:
	set(value):
		boat_direction = value
		boat_direction_updated.emit(value)

# --- World Location ---
signal world_location_updated(value: Vector3)
var world_location: Vector3:
	set(value):
		world_location = value
		world_location_updated.emit(value)

# ===
# Built-In
# ===

func reset() -> void:
	player_instance = null
	boat_instance = null
	gold = DEFAULT[Var.GOLD]
	equipped_boat = DEFAULT[Var.EQUIPPED_BOAT] as Enums.BoatType
	equipped_tool = DEFAULT[Var.EQUIPPED_TOOL] as Enums.ToolType
	look_direction = DEFAULT[Var.LOOK_DIR]
	boat_direction = DEFAULT[Var.BOAT_DIR]
	world_location = DEFAULT[Var.WORLD_LOC]

func to_dict() -> Dictionary[int, Variant]:
	return {
		Var.GOLD: gold,
		Var.EQUIPPED_BOAT: equipped_boat,
		Var.EQUIPPED_TOOL: equipped_tool,
		Var.LOOK_DIR: look_direction,
		Var.BOAT_DIR: boat_direction,
		Var.WORLD_LOC: world_location
	}

func from_dict(data: Dictionary[int, Variant]) -> void:
	gold = data.get(Var.GOLD, DEFAULT[Var.GOLD])
	equipped_boat = data.get(Var.EQUIPPED_BOAT, DEFAULT[Var.EQUIPPED_BOAT]) as Enums.BoatType
	equipped_tool = data.get(Var.EQUIPPED_TOOL, DEFAULT[Var.EQUIPPED_TOOL]) as Enums.ToolType
	look_direction = data.get(Var.LOOK_DIR, DEFAULT[Var.LOOK_DIR])
	boat_direction = data.get(Var.BOAT_DIR, DEFAULT[Var.BOAT_DIR])
	world_location = data.get(Var.WORLD_LOC, DEFAULT[Var.WORLD_LOC])

# ===
# Public
# ===

func purchase_boat(type: Enums.BoatType) -> void:
	var boat_data: BoatData = AssetProvider.get_boat_data(type)
	if not boat_data: 
		push_error("Purchase: Boat data not found for type %s" % type)
		return
	
	if gold >= boat_data.price:
		gold -= boat_data.price
		equipped_boat = type #
	else:
		push_warning("Purchase: Not enough gold for boat")

# ===
# Private
# ===
