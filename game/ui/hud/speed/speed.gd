@tool
class_name UIHUDSpeed
extends MarginContainer

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if is_node_ready():
			_update_icon()
@export var current_knots: float:
	set(value):
		current_knots = value
		if is_node_ready():
			_update_knots()

@onready var icon: TextureRect = %Icon
@onready var knots_label: Label = %Knots

# ===
# Built-In
# ===

func _ready() -> void:
	_update_icon()
	_update_knots()

# ===
# Private
# ===

func _update_icon() -> void:
	icon.texture = icon_texture

func _update_knots() -> void:
	# Round to x.x instead of x.xx
	var rounded_knots: float = round(current_knots * 10) / 10.0
	
	# Always show one decimal place (e.g., 12.0 instead of 12)
	knots_label.text = "%.1f" % rounded_knots
