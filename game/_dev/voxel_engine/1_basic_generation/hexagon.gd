class_name VoxelEngineBasicHexagonMesh
extends MeshInstance3D

@export var use_debug_colors: bool = false
@export var material: Material

var vertices: PackedVector3Array
var normals: PackedVector3Array
var colors: PackedColorArray

var debug_colors: Array[Color] = [
	Color.RED, Color.ORANGE, Color.YELLOW, 
	Color.GREEN, Color.BLUE, Color.PURPLE,
	Color.CYAN, Color.MAGENTA
]

func _ready() -> void:
	mesh = ArrayMesh.new()

func generate_mesh(data: Dictionary[Vector3, Color]) -> void:
	mesh.clear_surfaces()
	vertices = PackedVector3Array()
	normals = PackedVector3Array()
	colors = PackedColorArray()
	
	var height = 1.0
	var radius = 1.0
	
	for pos in data:
		var base_points: Array[Vector3] = []
		var top_points: Array[Vector3] = []
		
		for i in range(6):
			var angle = deg_to_rad(60.0 * i + 30.0)
			var offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
			base_points.append(pos + offset + Vector3(0, -height / 2.0, 0))
			top_points.append(pos + offset + Vector3(0, height / 2.0, 0))

		for i in range(6):
			var next = (i + 1) % 6
			var normal = (base_points[i] + base_points[next] - (pos * 2.0)).normalized()
			normal.y = 0
			var color = debug_colors[i % 6] if use_debug_colors else data[pos]
			add_side_face(base_points[i], base_points[next], top_points[next], top_points[i], normal, color)

		add_cap(top_points, true, debug_colors[6] if use_debug_colors else data[pos])
		add_cap(base_points, false, debug_colors[7] if use_debug_colors else data[pos])

	commit_mesh()
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
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	if material:
		mesh.surface_set_material(0, material)

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
