class_name VoxelEngineSurfaceCullingHexagonMesh
extends MeshInstance3D

@export var use_debug_colors: bool = false
@export var material: Material

var vertices: PackedVector3Array
var normals: PackedVector3Array
var colors: PackedColorArray

const RADIUS = 1.0
const HEIGHT = 1.0
const APOTHEM = 0.866025
const EPSILON = 0.05 # Increased slightly for float precision

func _ready() -> void:
	mesh = ArrayMesh.new()

func generate_mesh(data: Dictionary[Vector3, Color]) -> void:
	mesh.clear_surfaces()
	vertices = PackedVector3Array()
	normals = PackedVector3Array()
	colors = PackedColorArray()
	
	# Pre-calculate the 8 neighbor vectors to avoid repeated math
	var neighbor_dirs = []
	for i in range(6):
		var angle = deg_to_rad(60.0 * i + 30.0)
		neighbor_dirs.append(Vector3(cos(angle) * 2.0 * APOTHEM, 0, sin(angle) * 1.5))
	neighbor_dirs.append(Vector3(0, 1, 0))  # Up
	neighbor_dirs.append(Vector3(0, -1, 0)) # Down

	for pos in data:
		var color = data[pos]
		
		for i in range(8):
			# O(1) LOOKUP: No loops, just check if the exact key exists
			if not data.has(pos + neighbor_dirs[i]):
				if i < 6: add_side(pos, i, color)
				elif i == 6: add_cap(pos, true, color)
				elif i == 7: add_cap(pos, false, color)

	commit_mesh()
	commit_collision()

func is_neighbor_present(data: Dictionary[Vector3, Color], pos: Vector3, dir: Vector3) -> bool:
	var target = pos + dir
	for key in data:
		if key.distance_to(target) < EPSILON:
			return true
	return false

func add_side(pos: Vector3, side: int, color: Color) -> void:
	var a1 = deg_to_rad(60.0 * side + 30.0)
	var a2 = deg_to_rad(60.0 * (side + 1) + 30.0)
	
	var p1 = pos + Vector3(cos(a1) * RADIUS, -HEIGHT/2.0, sin(a1) * RADIUS)
	var p2 = pos + Vector3(cos(a2) * RADIUS, -HEIGHT/2.0, sin(a2) * RADIUS)
	var p3 = p2 + Vector3(0, HEIGHT, 0)
	var p4 = p1 + Vector3(0, HEIGHT, 0)
	
	var normal = (p1 + p2 - (pos * 2.0)).normalized()
	normal.y = 0
	
	add_triangle(p1, p2, p3, normal, color)
	add_triangle(p1, p3, p4, normal, color)

func add_cap(pos: Vector3, is_top: bool, color: Color) -> void:
	var center = pos + Vector3(0, (HEIGHT/2.0 if is_top else -HEIGHT/2.0), 0)
	var normal = Vector3.UP if is_top else Vector3.DOWN
	
	for i in range(6):
		var angle = deg_to_rad(60.0 * i + 30.0)
		var next_angle = deg_to_rad(60.0 * (i + 1) + 30.0)
		var p1 = pos + Vector3(cos(angle) * RADIUS, (HEIGHT/2.0 if is_top else -HEIGHT/2.0), sin(angle) * RADIUS)
		var p2 = pos + Vector3(cos(next_angle) * RADIUS, (HEIGHT/2.0 if is_top else -HEIGHT/2.0), sin(next_angle) * RADIUS)
		
		if is_top: add_triangle(center, p1, p2, normal, color)
		else: add_triangle(center, p2, p1, normal, color)

func add_triangle(p1, p2, p3, normal, color) -> void:
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
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	if material: mesh.surface_set_material(0, material)

# Use this instead of adding a StaticBody3D node to the scene
func commit_collision() -> void:
	var body_rid := PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body_rid, PhysicsServer3D.BODY_MODE_STATIC)
	
	var shape_rid := PhysicsServer3D.concave_polygon_shape_create()
	
	# Jolt specifically requires a dictionary for Concave Polygon shapes
	var shape_data := {
		"faces": vertices, # Your existing PackedVector3Array of vertices
		"backface_collision": false
	}
	
	PhysicsServer3D.shape_set_data(shape_rid, shape_data)
	
	PhysicsServer3D.body_add_shape(body_rid, shape_rid)
	PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
	PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, global_transform)
