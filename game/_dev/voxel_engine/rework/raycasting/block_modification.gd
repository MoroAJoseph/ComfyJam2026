class_name BlockModification 
extends RayCast3D

class RayHit:
	var remove_world_position: Vector3
	var add_world_position: Vector3
	
	func _init(rem: Vector3, add: Vector3):
		remove_world_position = rem
		add_world_position = add

# Replace get_ray_hit() in BlockModification.gd with this version:
func get_ray_hit() -> RayHit:
	var collider = get_collider()
	if collider is not Chunk: return null
	
	var point = get_collision_point()
	var normal = get_collision_normal()
	
	var remove_world = point - (normal * 0.01)
	var add_world = point + (normal * 0.01)
	
	return RayHit.new(remove_world, add_world)
