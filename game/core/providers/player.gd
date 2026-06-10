class_name PlayerProvider
extends ContextProvider

var context: PlayerContext

# ===
# Built-In
# ===

func _init(p_context: PlayerContext) -> void:
	context = p_context

func _process(delta: float) -> void:
	if context.boat_instance:
		context.boat_direction = context.boat_instance.get_direction()
		context.world_location = context.boat_instance.global_position

# ===
# Public
# ===

func set_boat_instance(value: Boat) -> void:
	context.boat_instance = value

func purchase_boat(type: Enums.BoatType) -> void:
	var boat_data: BoatData = AssetService.get_boat_data(type)
	if not boat_data: 
		push_error("Purchase: Boat data not found for type %s" % type)
		return
	
	if context.gold >= boat_data.price:
		context.gold -= boat_data.price
		context.equipped_boat = type #
	else:
		push_warning("Purchase: Not enough gold for boat")

func update_look_direction(value: Vector3) -> void:
	context.look_direction = value

func update_world_location(value: Vector3) -> void:
	context.world_location = value
