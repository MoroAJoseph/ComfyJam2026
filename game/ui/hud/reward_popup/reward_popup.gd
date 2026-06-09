extends Control

const REWARD_ITEM_SCENE = preload("res://ui/hud/reward_popup/reward_item.tscn")

@onready var scroll_container: HBoxContainer = %ScrollContainer
@onready var opening_strip: Control = %OpeningStrip
@onready var result_label: Label = %ResultLabel

var _current_tween: Tween
var _item_width: float = 150.0
var _separation: float = 10.0
var _win_index: int = 35
var _total_items: int = 45

var _is_showing: bool = false

# ===
# Built-In
# ===

func _ready() -> void:
	opening_strip.modulate.a = 0.0
	opening_strip.scale = Vector2(0.8, 0.8)
	result_label.modulate.a = 0.0
	EventBus.subscribe(WorldEvent.ChestCollected, _handle_chest_collected)
	Session.progression_context.chest_queue_updated.connect(_on_chest_queue_updated)
	_try_claim_next_chest()

# ===
# Private
# ===

func _try_claim_next_chest() -> void:
	if not _is_showing and not Session.progression_context.chest_queue.is_empty():
		Session.progression_provider.claim_next_chest()

# ===
# Event Handlers
# ===

func _on_chest_queue_updated(_value: Array) -> void:
	_try_claim_next_chest()

func _handle_chest_collected(event: WorldEvent.ChestCollected) -> void:
	pass
	#_show_reward(event)

func _show_reward(event: WorldEvent.ChestCollected) -> void:
	_is_showing = true
	
	if _current_tween:
		_current_tween.kill()
	
	# Clear old items
	for child in scroll_container.get_children():
		child.queue_free()
	
	# Reset position
	scroll_container.position.x = opening_strip.custom_minimum_size.x
	result_label.modulate.a = 0.0
	
	# Generate sequence
	var winning_item: Control = null
	
	for i in range(_total_items):
		var item = REWARD_ITEM_SCENE.instantiate()
		scroll_container.add_child(item)
		
		var rarity_data: Dictionary
		if i == _win_index:
			rarity_data = {
				"name": event.rarity_name,
				"color": event.color
			}
			winning_item = item
		else:
			# Random "filler" items based on some logic (mostly common/rare)
			var roll = randf()
			var rarity: Enums.RarityType = Enums.RarityType.COMMON
			if roll > 0.98: rarity = Enums.RarityType.LEGENDARY
			elif roll > 0.9: rarity = Enums.RarityType.EPIC
			elif roll > 0.7: rarity =Enums.RarityType.RARE
			
			#var data = Constants.LUT.get_chest_reward_data(rarity)
			#rarity_data = {
				#"name": data.name,
				#"color": data.color
			#}
		#
		#item.setup(rarity_data.name, rarity_data.color)

	# Calculate target X
	# Center of viewport - (index * step) - (half item width)
	var step = _item_width + _separation
	var target_x = (opening_strip.custom_minimum_size.x / 2.0) - (_win_index * step) - (_item_width / 2.0)
	
	# Add a random offset so it doesn't land perfectly in the center of the item every time
	target_x += randf_range(-(_item_width * 0.4), (_item_width * 0.4))
	
	_current_tween = create_tween().set_parallel(false)
	
	# 1. Show Strip
	_current_tween.tween_property(opening_strip, "modulate:a", 1.0, 0.2)
	_current_tween.parallel().tween_property(opening_strip, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
	
	# 2. Scroll Animation (The Spin)
	_current_tween.tween_property(scroll_container, "position:x", target_x, 4.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# 3. Highlight Result
	_current_tween.tween_callback(func():
		result_label.text = "+ %d Gold" % event.gold_amount
		result_label.modulate.a = 0.0
		
		var final_tween = create_tween().set_parallel(true)
		final_tween.tween_property(result_label, "modulate:a", 1.0, 0.3)
		final_tween.tween_property(winning_item, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_CUBIC)
		
		# Pulse the winning item
		var pulse = create_tween().set_loops(3)
		pulse.tween_property(winning_item, "modulate", Color(1.5, 1.5, 1.5), 0.1)
		pulse.tween_property(winning_item, "modulate", Color.WHITE, 0.1)
	)
	
	# 4. Wait and Hide
	_current_tween.tween_interval(2.5)
	_current_tween.tween_property(opening_strip, "modulate:a", 0.0, 0.5)
	_current_tween.parallel().tween_property(opening_strip, "scale", Vector2(0.8, 0.8), 0.5).set_trans(Tween.TRANS_CUBIC)
	
	# 5. Process Next
	_current_tween.tween_callback(func():
		_is_showing = false
		_try_claim_next_chest()
	)
