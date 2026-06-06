class_name ProgressionContext
extends RefCounted


# Equipped Boat Type
signal equipped_boat_type_updated(value: BoatData.Type)
var equipped_boat_type: BoatData.Type:
	set(value):
		equipped_boat_type = value
		equipped_boat_type_updated.emit(value)

# Equipped Tool Type
signal equipped_tool_type_updated(value: int)
var equipped_tool_type: int:
	set(value):
		equipped_tool_type = value
		equipped_tool_type_updated.emit(value)

# Gold
signal gold_updated(value: int)
var gold: int:
	set(value):
		gold = value
		gold_updated.emit(value)
