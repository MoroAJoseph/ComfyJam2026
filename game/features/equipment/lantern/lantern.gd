class_name Lantern
extends Node3D

@export var is_on := true:
	set(value):
		is_on = value
		if light:
			light.visible = is_on

@export var flicker_intensity := 0.2
@export var flicker_speed := 10.0

@onready var light: OmniLight3D = $OmniLight3D
@onready var _base_energy: float = light.light_energy

func _process(delta: float) -> void:
	if not is_on:
		return
	
	var flicker = (sin(Time.get_ticks_msec() * 0.001 * flicker_speed) + 
				  sin(Time.get_ticks_msec() * 0.001 * flicker_speed * 1.5)) * flicker_intensity
	light.light_energy = _base_energy + flicker

func toggle() -> void:
	is_on = !is_on
