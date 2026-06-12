@tool
class_name UIHUDDistance
extends MarginContainer

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if is_node_ready():
			_update_icon()
@export var kilometers: float:
	set(value):
		kilometers = value
		if is_node_ready():
			_update_distance()

@onready var icon: TextureRect = %Icon
@onready var distance: Label = %Distance

# ===
# Built-In
# ===

func _ready() -> void:
	_update_icon()
	_update_distance()

# ===
# Private
# ===
func _update_icon() -> void:
	icon.texture = icon_texture

func _update_distance() -> void:
	distance.text = str(kilometers)
