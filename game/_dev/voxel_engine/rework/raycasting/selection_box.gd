class_name SelectionBox 
extends Node3D

@export var ray: RayCast3D

@onready var sides: Dictionary[Vector3, CSGBox3D] = {
	Vector3(0, 1, 0): $Top, 
	Vector3(0, -1, 0): $Bottom,
	Vector3(0, 0, 1): $Left,
	Vector3(0, 0, -1): $Right,
	Vector3(1, 0, 0): $Front,
	Vector3(-1, 0, 0): $Back
}


func _physics_process(delta) -> void:
	if ray.is_colliding():
		visible = true
		var collision_normal = ray.get_collision_normal()
		var target_block = (ray.get_collision_point() - collision_normal * 0.01).floor()
		var collision_pos = target_block + Vector3(0.5, 0.5, 0.5)
		if collision_pos != global_position:
			for box_normal in sides:
				sides[box_normal].visible = false
				
			var normal_box = sides.get(collision_normal)
			if normal_box:
				normal_box.visible = true
			global_position = collision_pos
	else:
		visible = false
