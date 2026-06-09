extends HBoxContainer

@onready var _label: Label = %Label

var last_gold: int
var player_context: PlayerContext

# ===
# Built-In
# ===

func _ready() -> void:
	player_context = Session.player_context
	_update_gold_display()

func _process(_delta: float) -> void:
	if not player_context: return
	
	if player_context.gold != last_gold:
		_update_gold_display()

# ===
# Private
# ===

func _update_gold_display() -> void:
	last_gold = player_context.gold
	_label.text = str(player_context.gold)

# ===
# Event Handlers
# ===
