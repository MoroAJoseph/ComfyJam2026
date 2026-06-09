@tool
class_name InteractionArea
extends Area3D

@export var radius: float = 5.0:
	set(value):
		radius = value
		update_interaction_size()

@export var height: float = 5.0:
	set(value):
		height = value
		update_interaction_size()

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	update_interaction_size()

func update_interaction_size() -> void:
	if mesh_instance:
		# Use radius for X and Z, height for Y
		mesh_instance.scale = Vector3(radius, height, radius)
	
	if collision_shape:
		# If using a cylinder, adjust height and radius
		if collision_shape.shape is CylinderShape3D:
			collision_shape.shape.radius = radius
			collision_shape.shape.height = height
		# If using a sphere, treat height as the uniform scale if desired
		elif collision_shape.shape is SphereShape3D:
			collision_shape.shape.radius = radius
