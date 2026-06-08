class_name ProgressionContext
extends RefCounted


# Equipped Boat Type
signal equipped_boat_type_updated(value: Enums.BoatType)
var equipped_boat_type: Enums.BoatType:
	set(value):
		equipped_boat_type = value
		equipped_boat_type_updated.emit(value)

# Equipped Tool Type
signal equipped_tool_type_updated(value: Enums.ToolType)
var equipped_tool_type: Enums.ToolType:
	set(value):
		equipped_tool_type = value
		equipped_tool_type_updated.emit(value)

# Gold
signal gold_updated(value: int)
var gold: int:
	set(value):
		gold = value
		gold_updated.emit(value)

func purchase_boat(type: Enums.BoatType) -> void:
	var boat_data: BoatData = Constants.LUT.get_boat_data(type)
	if not boat_data:
		print_debug("Purchase: Boat data not found for type %s" % type)
		return
	
	if gold >= boat_data.price:
		gold -= boat_data.price
		equipped_boat_type = type
		print_debug("Purchase: Bought %s for %d gold" % [boat_data.display_name, boat_data.price])
	else:
		print_debug("Purchase: Not enough gold for %s" % boat_data.display_name)
