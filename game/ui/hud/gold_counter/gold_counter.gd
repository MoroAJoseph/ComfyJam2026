extends HBoxContainer

@onready var _label: Label = %Label

var last_gold: int
var progression_context: ProgressionContext

# ===
# Built-In
# ===

func _ready() -> void:
	progression_context = Context.progression
	_update_gold_display()

func _process(_delta: float) -> void:
	if not progression_context: return
	
	if progression_context.gold != last_gold:
		_update_gold_display()

# ===
# Private
# ===

func _update_gold_display() -> void:
	last_gold = progression_context.gold
	_label.text = str(progression_context.gold)

# ===
# Event Handlers
# ===
