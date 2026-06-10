class_name NewVoxelEngineChunk
extends StaticBody3D

var mesh_instance: MeshInstance3D
var collision_node: CollisionShape3D

func _init() -> void:
	# Keep nodes persistent to avoid allocation overhead during runtime
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	
	collision_node = CollisionShape3D.new()
	add_child(collision_node)

func update_state(geo: Dictionary, use_collision: bool) -> void:
	# Update Visuals
	if geo.vertices.is_empty():
		mesh_instance.mesh = null
	else:
		var array_mesh = ArrayMesh.new()
		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		surface_array[Mesh.ARRAY_VERTEX] = geo.vertices
		surface_array[Mesh.ARRAY_NORMAL] = geo.normals
		surface_array[Mesh.ARRAY_COLOR] = geo.colors
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
		mesh_instance.mesh = array_mesh

	# Update Collision
	if use_collision and not geo.vertices.is_empty():
		_update_collision(geo.vertices)
	else:
		collision_node.shape = null

func _update_collision(vertices: PackedVector3Array) -> void:
	# Reuse the existing collision_node rather than creating new nodes
	var shape = ConcavePolygonShape3D.new()
	shape.data = {
		"faces": vertices,
		"backface_collision": false
	}
	collision_node.shape = shape

func get_collision_rid() -> RID:
	# Returns the RID needed for the Manager's rid_to_coordinate map
	return collision_node.get_rid()
