class_name Lighthouse
extends Node3D

@onready var light_pivot: Node3D = $LightPivot
@onready var spot_forward: SpotLight3D = $LightPivot/SpotLight_Forward
@onready var spot_backward: SpotLight3D = $LightPivot/SpotLight_Backward
@onready var lamp_light: OmniLight3D = $LampLight

@export_group("Rotation")
@export var rotation_speed: float = 1.0

@export_group("Atmosphere")
@export var flicker_intensity: float = 0.05
@export var flicker_speed: float = 4.0

var _time: float = 0.0
var _base_spot_energy: float = 64.0
var _base_lamp_energy: float = 20.0

func _ready() -> void:
	if spot_forward:
		_base_spot_energy = spot_forward.light_energy
	if lamp_light:
		_base_lamp_energy = lamp_light.light_energy

func _process(delta: float) -> void:
	_time += delta
	
	# Rotation
	if light_pivot:
		light_pivot.rotate_y(rotation_speed * delta)
	
	# Day/Night Visibility
	var night_weight = _get_night_weight()
	
	# Atmospheric flicker (subtle intensity modulation)
	var flicker = 1.0 + (sin(_time * flicker_speed) * flicker_intensity)
	flicker += (sin(_time * flicker_speed * 2.5) * flicker_intensity * 0.5)
	
	# Apply final energy
	var final_spot_energy = _base_spot_energy * flicker * night_weight
	var final_lamp_energy = _base_lamp_energy * flicker * night_weight
	
	if spot_forward:
		spot_forward.light_energy = final_spot_energy
		spot_forward.visible = final_spot_energy > 0.01
	if spot_backward:
		spot_backward.light_energy = final_spot_energy
		spot_backward.visible = final_spot_energy > 0.01
	if lamp_light:
		lamp_light.light_energy = final_lamp_energy
		lamp_light.visible = final_lamp_energy > 0.01

func _get_night_weight() -> float:
	if not Context.world:
		return 1.0
		
	var world_time = Context.world.time
	
	# Night is around 0.0 and 1.0. Day is around 0.5.
	# Transition ranges: 
	# 0.15 - 0.25 (Sunrise: Fade Out)
	# 0.75 - 0.85 (Sunset: Fade In)
	
	if world_time < 0.15:
		return 1.0
	if world_time < 0.25:
		return remap(world_time, 0.15, 0.25, 1.0, 0.0)
	if world_time < 0.75:
		return 0.0
	if world_time < 0.85:
		return remap(world_time, 0.75, 0.85, 0.0, 1.0)
		
	return 1.0
