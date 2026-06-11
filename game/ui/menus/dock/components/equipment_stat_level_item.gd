@tool
class_name UIEquipmentStatLevelItem
extends MarginContainer

@export var is_filled: bool = false:
	set(value):
		is_filled = value
		if is_node_ready(): _update_view()

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if is_node_ready(): _update_color()

@onready var filled: ColorRect = $Filled
@onready var empty: ColorRect = $Empty

# ===
# Built-In
# ===

func _ready() -> void:
	_update_view()
	_update_color()

# ===
# Private
# ===

func _update_view() -> void:
	if filled and empty:
		filled.visible = is_filled
		empty.visible = not is_filled

func _update_color() -> void:
	if filled and empty:
		filled.color = color
		empty.color = color
