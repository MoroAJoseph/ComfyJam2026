class_name VoxelEngineSurfaceCullingCubeMesh
extends MeshInstance3D

enum Face {
	FRONT, 
	BACK,
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}

@export var use_debug_colors: bool = false
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

var debug_colors: Dictionary[Face, Color] = {
	Face.FRONT: Color.ORANGE,
	Face.BACK: Color.PURPLE,
	Face.LEFT: Color.BLUE,
	Face.RIGHT: Color.YELLOW,
	Face.TOP: Color.GREEN,
	Face.BOTTOM: Color.RED,
}

func _ready() -> void:
	mesh = ArrayMesh.new()
	surface_array.resize(Mesh.ARRAY_MAX)

func generate_mesh(data: Dictionary[Vector3, Color]) -> void:
	for pos in data:
		var color = data[pos]
		if not has_neighbour(data, Face.FRONT, pos):
			add_face(Face.FRONT, pos, color)
		if not has_neighbour(data, Face.BACK, pos):
			add_face(Face.BACK, pos, color)
		if not has_neighbour(data, Face.LEFT, pos):
			add_face(Face.LEFT, pos, color)
		if not has_neighbour(data, Face.RIGHT, pos):
			add_face(Face.RIGHT, pos, color)
		if not has_neighbour(data, Face.TOP, pos):
			add_face(Face.TOP, pos, color)
		if not has_neighbour(data, Face.BOTTOM, pos):
			add_face(Face.BOTTOM, pos, color)

	commit_mesh()
	#commit_collision()

func has_neighbour(data: Dictionary[Vector3, Color], face: Face, pos: Vector3) -> bool:
	var neighbour_position = pos + face_normals[face]
	return data.has(neighbour_position)

func add_face(face: Face, pos: Vector3, color: Color) -> void:
	var indices = face_indices[face]
	for triangle in indices:
		for index in triangle:
			vertices.append(cube_vertices[index] + pos)
			normals.append(face_normals[face])
			if use_debug_colors:
				colors.append(debug_colors[face])
			else:
				colors.append(color)

func commit_mesh() -> void:
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_COLOR] = colors
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, material)

func commit_collision() -> void:
	var static_body := StaticBody3D.new()
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = mesh.create_trimesh_shape()
	static_body.add_child(collision_shape)
	add_child(static_body)
