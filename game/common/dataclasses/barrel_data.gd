class_name BarrelData
extends RefCounted

var type: Enums.BarrelType
var color: Color
var explosion_force: float
var explosion_radius: float
var vertical_boost: float
var torque_force: float

func _init(
	p_type: Enums.BarrelType,
	p_color: Color,
	p_explosion_force: float,
	p_explosion_radius: float,
	p_vertical_boost: float,
	p_torque_force: float,
) -> void:
	type = p_type
	color = p_color
	explosion_force = p_explosion_force
	explosion_radius = p_explosion_radius
	vertical_boost = p_vertical_boost
	torque_force = p_torque_force
