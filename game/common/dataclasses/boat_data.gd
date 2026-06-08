class_name BoatData
extends Resource

@export_category("Identity")
@export var type: Enums.BoatType
@export var display_name: String

@export_category("Physics")
@export var max_speed: float = 20.0
@export var acceleration: float = 8.0
@export var turn_speed: float = 3.0
@export var collision_damping: float = 0.2
@export var hull_drag: float = 0.5
@export var angular_drag: float = 2.0

@export_category("Logistics")
@export var price: int = 0
@export var inventory_capacity: int = 100
@export var max_zoom: int = 12
@export var min_zoom: int = 6
@export var zoom_step: int = 2

func _init(
	p_type: Enums.BoatType,
	p_max_speed: float, 
	p_acceleration: float, 
	p_turn_speed: float, 
	p_collision_damping: float,
	p_hull_drag: float, 
	p_angular_drag: float, 
	p_price: int,
	p_inventory_capacity: int,
	p_max_zoom: int,
	p_min_zoom: int,
	p_zoom_step: int,
) -> void:
	type = p_type
	display_name = Enums.BoatType.keys()[p_type].capitalize()
	max_speed = p_max_speed
	acceleration = p_acceleration
	turn_speed = p_turn_speed
	collision_damping = p_collision_damping
	hull_drag = p_hull_drag
	angular_drag = p_angular_drag
	price = p_price
	inventory_capacity = p_inventory_capacity
	max_zoom = p_max_zoom
	min_zoom = p_min_zoom
	zoom_step = p_zoom_step
