class_name VoxelEngineBasicCubeMesh
extends MeshInstance3D

enum Face {
	FRONT, 
	BACK,
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}

@export var material: Material

var surface_array : Array = []
var vertices: PackedVector3Array
var normals: PackedVector3Array
var colors: PackedColorArray

var cube_vertices: Array[Vector3] = [
	Vector3(-0.5, -0.5, 0.5), 	# --+
	Vector3(0.5, -0.5, 0.5), 	# +-+
	Vector3(0.5, -0.5, -0.5), 	# +--
	Vector3(-0.5, -0.5, -0.5), 	# ---
	Vector3(-0.5, 0.5, 0.5), 	# -++
	Vector3(0.5, 0.5, 0.5), 	# +++
	Vector3(0.5, 0.5, -0.5), 	# ++-
	Vector3(-0.5, 0.5, -0.5), 	# -+-
]

# NOTE: Godot uses clockwise
var face_indices: Dictionary[Face, Array] = {
	Face.FRONT: [[0, 4, 5], [0, 5, 1]],
	Face.BACK: [[2, 7, 3], [2, 6, 7]],
	Face.LEFT: [[3, 7, 4], [3, 4, 0]],
	Face.RIGHT: [[1, 5, 6], [1, 6, 2]],
	Face.TOP: [[0, 1, 2], [0, 2, 3]],
	Face.BOTTOM: [[4, 7, 6], [4, 6, 5]]
}

var face_normals: Dictionary[Face, Vector3] = {
	Face.FRONT: Vector3(0, 0, 1),
	Face.BACK: Vector3(0, 0, -1),
	Face.LEFT: Vector3(-1, 0, 0),
	Face.RIGHT: Vector3(1, 0, 0),
	Face.TOP: Vector3(0, -1, 0),
	Face.BOTTOM: Vector3(0, 1, 0),
}

var face_colors: Dictionary[Face, Color] = {
	Face.FRONT: Color.ORANGE,
	Face.BACK: Color.PURPLE,
	Face.LEFT: Color.BLUE,
	Face.RIGHT: Color.YELLOW,
	Face.TOP: Color.GREEN,
	Face.BOTTOM: Color.RED,
}

func _ready() -> void:
	surface_array.resize(Mesh.ARRAY_MAX)

func generate_mesh(data: Dictionary) -> void:
	for pos in data:
		add_face(Face.FRONT, pos)
		add_face(Face.BACK, pos)
		add_face(Face.LEFT, pos)
		add_face(Face.RIGHT, pos)
		add_face(Face.TOP, pos)
		add_face(Face.BOTTOM, pos)

	commit_mesh()
	commit_collision()

func has_neighbour(data: Dictionary[Vector3, Color], face: Face, pos: Vector3) -> bool:
	var neighbour_position = pos + face_normals[face]
	return data.has(neighbour_position)

func add_face(face: Face, pos: Vector3) -> void:
	var indices = face_indices[face]
	for triangle in indices:
		for index in triangle:
			vertices.append(cube_vertices[index] + pos)
			normals.append(face_normals[face])
			colors.append(face_colors[face])

func commit_mesh() -> void:
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_COLOR] = colors
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
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
