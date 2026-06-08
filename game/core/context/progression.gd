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

func add_chest(type: Enums.ChestType) -> void:
	_reward_chest(type)

func _reward_chest(type: Enums.ChestType) -> void:
	var roll = randf()
	var cumulative_prob = 0.0
	
	var data: ChestData = Constants.LUT.get_chest_data(type)
	var table = data.rarity_drop_table
	var reward_data: ChestRewardData
	var gold_amount: int = 0
	
	for rarity in Enums.RarityType.values():
		cumulative_prob += table[rarity] 
		
		if roll <= cumulative_prob:
			reward_data = Constants.LUT.get_chest_reward_data(rarity)
			gold_amount = randi_range(reward_data.min_gold, reward_data.max_gold)
			break

	# Update Gold
	gold += gold_amount
	
	# Emit Event for UI/Sound
	EventBus.emit(
		WorldEvent.ChestCollected.new(
			reward_data.rarity,
			reward_data.name,
			reward_data.color,
			gold_amount
		)
	)

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
