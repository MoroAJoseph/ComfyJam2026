class_name TestVoxelEngineMeshBuilder 
extends RefCounted

## Converts voxel data into geometry and physics structures
static func build_geometry(
	data: PackedByteArray, 
	coord: Vector3i, 
	registry: Dictionary, 
	chunk_size: int, 
	colors: Array[Color],
	logic_class: Object
) -> Dictionary:
	return logic_class.calculate_geometry(data, coord, registry, chunk_size, colors)

static func update_physics_server(
	body_rid: RID, 
	shape_rid: RID, 
	verts: PackedVector3Array, 
	transform: Transform3D
) -> void:
	if not shape_rid.is_valid():
		return
		
	PhysicsServer3D.shape_set_data(shape_rid, {"faces": verts, "backface_collision": false})
	PhysicsServer3D.body_set_state(
		body_rid, 
		PhysicsServer3D.BODY_STATE_TRANSFORM, 
		transform
	)
