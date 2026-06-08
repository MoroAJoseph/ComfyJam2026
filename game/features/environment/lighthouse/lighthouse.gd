class_name Lighthouse
extends Node3D

@onready var tower: Node3D = $tower_complete_large
@onready var light_pivot: Node3D = $LightPivot

@export var rotation_speed: float = 1.0

func _process(delta: float) -> void:
	if light_pivot:
		light_pivot.rotate_y(rotation_speed * delta)
