class_name VoxelEngineBlockRay
extends RayCast3D

class RayHit:
	var remove_position: Vector3i
	var add_position: Vector3i
	
	func _init(p_remove_position: Vector3i, p_add_position: Vector3i) -> void:
		remove_position = p_remove_position
		add_position = p_add_position

func get_ray_hit() -> RayHit:
	return RayHit.new(Vector3.ZERO, Vector3.ZERO)
	#var collider = get_collider()
	#if collider is not Chunk: return null
	#
	#var chunk = collider as Chunk
	#var point = get_collision_point()
	#var normal = get_collision_normal()
	#var pos = (point - normal / 2).floor()
	#
	#return RayHit.new(pos, pos + normal)
	#
