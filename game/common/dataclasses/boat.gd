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

@export_category("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
@export var inventory_capacity: int = 100

@export_category("Camera")
@export var max_zoom: int = 12
@export var min_zoom: int = 6
@export var zoom_step: int = 2
