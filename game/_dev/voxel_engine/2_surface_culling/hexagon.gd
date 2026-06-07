class_name VoxelEngineSurfaceCullingHexagonMesh
extends Node3D

@export var use_rendering_server: bool = true
@export var use_physics_server: bool = false
@export var generate_collision: bool = false
@export var use_debug_colors: bool = false
@export var material: Material

var vertices: PackedVector3Array
var normals: PackedVector3Array
var colors: PackedColorArray

# RID-based rendering
var mesh_rid: RID
var instance_rid: RID
# Node-based rendering
var mesh_node: MeshInstance3D

var debug_colors: Array[Color] = [
	Color.RED, Color.ORANGE, Color.YELLOW, 
	Color.GREEN, Color.BLUE, Color.PURPLE,
	Color.CYAN, Color.MAGENTA
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

func generate_mesh(data: Dictionary[Vector3i, Color]) -> void:
	vertices = PackedVector3Array()
	normals = PackedVector3Array()
	colors = PackedColorArray()
	
	var height = 1.0
	var size = 1.0 
	
	for pos in data:
		var x = size * (3.0 / 2.0 * pos.x)
		var z = size * (sqrt(3.0) / 2.0 * pos.x + sqrt(3.0) * pos.z)
		var y_world = pos.y * height
		var center_v3 = Vector3(x, y_world, z)
		
		var base_points: Array[Vector3] = []
		var top_points: Array[Vector3] = []
		
		for i in range(6):
			var angle = deg_to_rad(60.0 * i)
			var offset = Vector3(cos(angle) * size, 0, sin(angle) * size)
			base_points.append(center_v3 + offset + Vector3(0, -height / 2.0, 0))
			top_points.append(center_v3 + offset + Vector3(0, height / 2.0, 0))

		for i in range(6):
			var next = (i + 1) % 6
			var normal = (base_points[i] + base_points[next] - (center_v3 * 2.0)).normalized()
			normal.y = 0
			var color = debug_colors[i % 6] if use_debug_colors else data[pos]
			add_side_face(base_points[i], base_points[next], top_points[next], top_points[i], normal, color)

		add_cap(top_points, true, debug_colors[6] if use_debug_colors else data[pos])
		add_cap(base_points, false, debug_colors[7] if use_debug_colors else data[pos])

	commit_mesh()
	if generate_collision:
		commit_collision()

func add_side_face(p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3, normal: Vector3, color: Color) -> void:
	add_triangle(p1, p2, p3, normal, color)
	add_triangle(p1, p3, p4, normal, color)

func add_cap(points: Array[Vector3], is_top: bool, color: Color) -> void:
	var center = Vector3.ZERO
	for p in points: center += p
	center /= 6.0
	
	var normal = Vector3.UP if is_top else Vector3.DOWN
	for i in range(6):
		var next = (i + 1) % 6
		if is_top:
			add_triangle(center, points[i], points[next], normal, color)
		else:
			add_triangle(center, points[next], points[i], normal, color)

func add_triangle(p1: Vector3, p2: Vector3, p3: Vector3, normal: Vector3, color: Color) -> void:
	vertices.append_array([p1, p2, p3])
	for i in range(3):
		normals.append(normal)
		colors.append(color)

func commit_mesh() -> void:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_COLOR] = colors
	
	if use_rendering_server:
		RenderingServer.mesh_clear(mesh_rid)
		RenderingServer.mesh_add_surface_from_arrays(mesh_rid, RenderingServer.PRIMITIVE_TRIANGLES, surface_array)
		if material:
			RenderingServer.mesh_surface_set_material(mesh_rid, 0, material.get_rid())
	else:
		mesh_node.mesh.clear_surfaces()
		mesh_node.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
		if material:
			mesh_node.set_surface_override_material(0, material)

func commit_collision() -> void:
	if use_physics_server:
		var body_rid := PhysicsServer3D.body_create()
		PhysicsServer3D.body_set_mode(body_rid, PhysicsServer3D.BODY_MODE_STATIC)
		var shape_rid := PhysicsServer3D.concave_polygon_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, {"faces": vertices, "backface_collision": false})
		PhysicsServer3D.body_add_shape(body_rid, shape_rid)
		PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
		PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, global_transform)
	else:
		var static_body := StaticBody3D.new()
		var collision_shape := CollisionShape3D.new()
		var temp_mesh = ArrayMesh.new()
		var arr = []
		arr.resize(Mesh.ARRAY_MAX)
		arr[Mesh.ARRAY_VERTEX] = vertices
		temp_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
		collision_shape.shape = temp_mesh.create_trimesh_shape()
		static_body.add_child(collision_shape)
		add_child(static_body)

func _exit_tree() -> void:
	if use_rendering_server:
		RenderingServer.free_rid(instance_rid)
		RenderingServer.free_rid(mesh_rid)
