class_name ProgressionProvider
extends ContextProvider

var context: ProgressionContext
var player_context: PlayerContext

# ===
# Built-In
# ===

func _init(
	p_context: ProgressionContext, 
	p_player: PlayerContext
) -> void:
	context = p_context
	player_context = p_player

# ===
# Public
# ===

func add_chest(type: Enums.ChestType) -> void:
	context.chest_queue.append(type)
	context.chest_queue_updated.emit(context.chest_queue)

func claim_next_chest() -> void:
	if context.chest_queue.is_empty(): return
	var type: Enums.ChestType = context.chest_queue.pop_front()
	_reward_chest(type)
	context.chest_queue_updated.emit(context.chest_queue)

# ===
# Private
# ===

func _reward_chest(type: Enums.ChestType) -> void:
	var roll := randf()
	var cumulative_prob := 0.0
	
	var data: ChestData = AssetService.get_chest_data(type)
	var table := data.rarity_drop_table
	
	var selected_rarity: Enums.RarityType
	var gold_amount: int = 0
	
	# Determine the Rarity based on probability
	for rarity in Enums.RarityType.values():
		cumulative_prob += table[rarity]
		
		if roll <= cumulative_prob:
			selected_rarity = rarity
			
			# Look up the reward range from the Matrix in Constants
			var key := Vector2i(type, selected_rarity)
			var range_vec := Constants.CHEST_REWARD_MATRIX[key]
			
			# Calculate Gold
			gold_amount = randi_range(range_vec.x, range_vec.y)
			break

	# Update Player Gold
	player_context.gold += gold_amount
	
	# Emit Event for UI/Sound
	EventBus.emit(
		WorldEvent.ChestCollected.new(
			selected_rarity,
			data.name, # Using the ChestData name
			data.color,
			gold_amount
		)
	)
