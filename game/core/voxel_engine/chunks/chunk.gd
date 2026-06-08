class_name VoxelEngineChunk
extends StaticBody3D

var material: Material
var mesh_instance: MeshInstance3D
var body_rid: RID
var shape_rid: RID

# ===
# Built-In
# ===

func _ready() -> void:
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = ArrayMesh.new()
	add_child(mesh_instance)
	_create_and_apply_material()

func _exit_tree() -> void:
	if body_rid.is_valid(): PhysicsServer3D.free_rid(body_rid)
	if shape_rid.is_valid(): PhysicsServer3D.free_rid(shape_rid)

# ===
# Public
# ===

func apply_geometry(geo: Dictionary) -> void:
	if geo.verts.is_empty():
		mesh_instance.mesh.clear_surfaces()
		return

	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = geo.verts
	arr[Mesh.ARRAY_NORMAL] = geo.norms
	arr[Mesh.ARRAY_COLOR] = geo.cols
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	mesh_instance.mesh = array_mesh
	
	if material:
		mesh_instance.set_surface_override_material(0, material)

func apply_collision(verts: PackedVector3Array) -> void:
	if body_rid.is_valid(): 
		PhysicsServer3D.free_rid(body_rid)
		PhysicsServer3D.free_rid(shape_rid)
		
	body_rid = PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body_rid, PhysicsServer3D.BODY_MODE_STATIC)
	
	shape_rid = PhysicsServer3D.concave_polygon_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid, {"faces": verts, "backface_collision": false})
	
	PhysicsServer3D.body_add_shape(body_rid, shape_rid)
	PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
	PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, global_transform)

# ===
# Private
# ===

func _create_and_apply_material() -> void:
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = preload("res://core/voxel_engine/hexagon.gdshader")
	shader_mat.set_shader_parameter("atlas", preload("res://assets/blocks/hexagon_uv_atlas.png"))
	
	material = shader_mat
	mesh_instance.set_surface_override_material(0, material)
