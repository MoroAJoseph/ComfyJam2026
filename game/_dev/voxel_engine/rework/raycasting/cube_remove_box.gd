class_name CubeRemoveBox 
extends CSGBox3D

@export var ray: RayCast3D

func _physics_process(_delta: float) -> void:
	if ray.is_colliding():
		visible = true
		var collision_normal = ray.get_collision_normal()
		var target_block = (ray.get_collision_point() - collision_normal * 0.01).floor()
		var collision_pos = target_block + Vector3(0.5, 0.5, 0.5)
		if collision_pos != global_position:
			global_position = collision_pos
	else:
		visible = false
