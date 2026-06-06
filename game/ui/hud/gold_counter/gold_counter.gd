extends HBoxContainer

@onready var _label: Label = %Label

# ===
# Built-In
# ===

func _ready() -> void:
	_update_gold_display()
	# We can use a signal if we add one to PlayerContext later, 
	# but for now we can update it when the HUD is toggled or via events.
	EventBus.subscribe(GameEvent.GoldUpdated, _on_gold_updated)

func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvent.GoldUpdated, _on_gold_updated)

# ===
# Private
# ===

func _update_gold_display() -> void:
	_label.text = str(Context.player.gold)

# ===
# Event Handlers
# ===

func _on_gold_updated(_event: GameEvent.GoldUpdated) -> void:
	_update_gold_display()
