class_name VoxelEngineChunkingHexagonChunk
extends StaticBody3D

@export var use_rendering_server: bool = true
@export var use_physics_server: bool = false
@export var generate_collision: bool = false
@export var use_debug_colors: bool = false
@export var material: Material

# Thread-safe data buffers
var prepared_vertices: PackedVector3Array
var prepared_normals: PackedVector3Array
var prepared_colors: PackedColorArray

var mesh_rid: RID
var instance_rid: RID
var mesh_node: MeshInstance3D

# Hexagonal neighbor offsets for flat-topped axial coordinates
const NEIGHBORS = [
	Vector3i(1, 0, 0), 
	Vector3i(-1, 0, 0),
	Vector3i(0, 0, 1), 
	Vector3i(0, 0, -1),
	Vector3i(1, 0, -1), 
	Vector3i(-1, 0, 1)
]

const FACE_TO_NEIGHBOR_MAP = [
	Vector3i(1, 0, 0),    # Face 0 -> +X
	Vector3i(0, 0, 1),    # Face 1 -> +Z
	Vector3i(-1, 0, 1),   # Face 2 -> -X+Z
	Vector3i(-1, 0, 0),   # Face 3 -> -X
	Vector3i(0, 0, -1),   # Face 4 -> -Z
	Vector3i(1, 0, -1)    # Face 5 -> +X-Z
]

func _init() -> void:
	mesh_rid = RenderingServer.mesh_create()
	instance_rid = RenderingServer.instance_create()

func _ready() -> void:
	if use_rendering_server:
		RenderingServer.instance_set_base(instance_rid, mesh_rid)
		RenderingServer.instance_set_scenario(instance_rid, get_world_3d().scenario)
	else:
		mesh_node = MeshInstance3D.new()
		mesh_node.mesh = ArrayMesh.new()
		add_child(mesh_node)

# --- THREAD-SAFE GENERATION ---
func prepare_mesh_data(data: Dictionary[Vector3i, Color]) -> void:
	prepared_vertices = PackedVector3Array()
	prepared_normals = PackedVector3Array()
	prepared_colors = PackedColorArray()
	
	var height = 1.0
	var size = 1.0 
	
	for pos in data:
		var center_v3 = _get_hex_world_pos(pos, size, height)
		var base_points = _get_hex_points(center_v3, size, -height / 2.0)
		var top_points = _get_hex_points(center_v3, size, height / 2.0)

		# Cull vertical neighbors
		if not data.has(pos + Vector3i(0, 1, 0)):
			_add_cap_prepared(top_points, true, data[pos])
		if not data.has(pos + Vector3i(0, -1, 0)):
			_add_cap_prepared(base_points, false, data[pos])

		# Cull side neighbors
		for i in range(6):
			if not data.has(pos + FACE_TO_NEIGHBOR_MAP[i]):
				var next = (i + 1) % 6
				var normal = (base_points[i] + base_points[next] - (center_v3 * 2.0)).normalized()
				normal.y = 0
				_add_side_prepared(base_points[i], base_points[next], top_points[next], top_points[i], normal, data[pos])

func _get_hex_world_pos(pos: Vector3i, size: float, height: float) -> Vector3:
	return Vector3(size * (1.5 * pos.x), pos.y * height, size * (sqrt(3.0) * (pos.z + 0.5 * pos.x)))

func _get_hex_points(center: Vector3, size: float, y_offset: float) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for i in range(6):
		var angle = deg_to_rad(60.0 * i)
		points.append(center + Vector3(cos(angle) * size, y_offset, sin(angle) * size))
	return points

func _add_side_prepared(p1, p2, p3, p4, normal, color):
	_add_tri(p1, p2, p3, normal, color)
	_add_tri(p1, p3, p4, normal, color)

func _add_cap_prepared(points, is_top, color):
	var center = Vector3.ZERO
	for p in points: center += p
	center /= 6.0
	var normal = Vector3.UP if is_top else Vector3.DOWN
	for i in range(6):
		var next = (i + 1) % 6
		if is_top: _add_tri(center, points[i], points[next], normal, color)
		else: _add_tri(center, points[next], points[i], normal, color)

func _add_tri(p1, p2, p3, normal, color):
	prepared_vertices.append_array([p1, p2, p3])
	for i in range(3):
		prepared_normals.append(normal)
		prepared_colors.append(color)

# --- MAIN THREAD FINALIZATION ---
func apply_prepared_mesh() -> void:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = prepared_vertices
	surface_array[Mesh.ARRAY_NORMAL] = prepared_normals
	surface_array[Mesh.ARRAY_COLOR] = prepared_colors
	
	if use_rendering_server:
		RenderingServer.mesh_clear(mesh_rid)
		RenderingServer.mesh_add_surface_from_arrays(mesh_rid, RenderingServer.PRIMITIVE_TRIANGLES, surface_array)
		if material: RenderingServer.mesh_surface_set_material(mesh_rid, 0, material.get_rid())
	else:
		mesh_node.mesh.clear_surfaces()
		mesh_node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
		if material: mesh_node.set_surface_override_material(0, material)
	
	if generate_collision:
		commit_collision()

func commit_collision() -> void:
	if use_physics_server:
		var body_rid := PhysicsServer3D.body_create()
		PhysicsServer3D.body_set_mode(body_rid, PhysicsServer3D.BODY_MODE_STATIC)
		var shape_rid := PhysicsServer3D.concave_polygon_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, {"faces": prepared_vertices, "backface_collision": false})
		PhysicsServer3D.body_add_shape(body_rid, shape_rid)
		PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
		PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, global_transform)
	else:
		var static_body := StaticBody3D.new()
		var collision_shape := CollisionShape3D.new()
		var temp_mesh = ArrayMesh.new()
		var arr = []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = prepared_vertices
		temp_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		collision_shape.shape = temp_mesh.create_trimesh_shape()
		static_body.add_child(collision_shape)
		add_child(static_body)

func _exit_tree() -> void:
	if use_rendering_server:
		RenderingServer.free_rid(instance_rid)
		RenderingServer.free_rid(mesh_rid)
