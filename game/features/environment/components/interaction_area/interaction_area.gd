@tool
class_name InteractionArea
extends Area3D

@export var radius: float = 5.0:
	set(value):
		radius = value
		_update_interaction_size()

@export var mesh_height: float = 5.0:
	set(value):
		mesh_height = value
		_update_interaction_size()

@export var collision_height: float = 3.0:
	set(value):
		collision_height = value
		_update_collision_height()

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# ===
# Built-In
# ===

func _ready() -> void:
	_update_interaction_size()
	_update_collision_height()

# ===
# Private
# ===

func _update_interaction_size() -> void:
	if not (
		mesh_instance and 
		collision_shape
	): return
		
	mesh_instance.scale = Vector3(radius, mesh_height, radius)
	
	if collision_shape.shape:
		collision_shape.shape.radius = radius

func _update_collision_height() -> void:
	if collision_shape: return
	collision_shape.shape.height = collision_height
