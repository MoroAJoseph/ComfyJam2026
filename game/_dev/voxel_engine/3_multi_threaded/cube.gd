class_name VoxelEngineMultiThreadedCubeMesh
extends MeshInstance3D

enum Face { FRONT, BACK, LEFT, RIGHT, TOP, BOTTOM }

@export var use_debug_colors: bool = false
@export var material: Material

var prepared_vertices: PackedVector3Array
var prepared_normals: PackedVector3Array
var prepared_colors: PackedColorArray

var cube_vertices: Array[Vector3] = [
	Vector3(-0.5, -0.5, 0.5), Vector3(0.5, -0.5, 0.5),
	Vector3(0.5, -0.5, -0.5), Vector3(-0.5, -0.5, -0.5),
	Vector3(-0.5, 0.5, 0.5), Vector3(0.5, 0.5, 0.5),
	Vector3(0.5, 0.5, -0.5), Vector3(-0.5, 0.5, -0.5)
]

var face_indices: Dictionary[Face, Array] = {
	Face.FRONT: [[0, 4, 5], [0, 5, 1]],
	Face.BACK: [[2, 7, 3], [2, 6, 7]],
	Face.LEFT: [[3, 7, 4], [3, 4, 0]],
	Face.RIGHT: [[1, 5, 6], [1, 6, 2]],
	Face.TOP: [[0, 1, 2], [0, 2, 3]],
	Face.BOTTOM: [[4, 7, 6], [4, 6, 5]]
}

var face_normals: Dictionary[Face, Vector3] = {
	Face.FRONT: Vector3(0, 0, 1), Face.BACK: Vector3(0, 0, -1),
	Face.LEFT: Vector3(-1, 0, 0), Face.RIGHT: Vector3(1, 0, 0),
	Face.TOP: Vector3(0, -1, 0), Face.BOTTOM: Vector3(0, 1, 0)
}

var debug_colors: Dictionary[Face, Color] = {
	Face.FRONT: Color.ORANGE, Face.BACK: Color.PURPLE,
	Face.LEFT: Color.BLUE, Face.RIGHT: Color.YELLOW,
	Face.TOP: Color.GREEN, Face.BOTTOM: Color.RED
}

func _ready() -> void:
	mesh = ArrayMesh.new()

# CRITICAL: THREAD-SAFE: Calculates geometry without touching the SceneTree
func prepare_mesh_data(data: Dictionary[Vector3, Color]) -> void:
	prepared_vertices = PackedVector3Array()
	prepared_normals = PackedVector3Array()
	prepared_colors = PackedColorArray()
	
	for pos in data:
		var color = data[pos]
		for face in Face.values():
			if not data.has(pos + face_normals[face]):
				add_face_to_prepared(face, pos, color)

func add_face_to_prepared(face: Face, pos: Vector3, color: Color) -> void:
	var indices = face_indices[face]
	for triangle in indices:
		for index in triangle:
			prepared_vertices.append(cube_vertices[index] + pos)
			prepared_normals.append(face_normals[face])
			prepared_colors.append(debug_colors[face] if use_debug_colors else color)

# CRITICAL: MAIN THREAD ONLY: Finalizes the mesh on the GPU
func apply_prepared_mesh() -> void:
	mesh.clear_surfaces()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = prepared_vertices
	surface_array[Mesh.ARRAY_NORMAL] = prepared_normals
	surface_array[Mesh.ARRAY_COLOR] = prepared_colors
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, material)

# CRITICAL: MAIN THREAD ONLY
func commit_collision() -> void:
	var static_body := StaticBody3D.new()
	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = mesh.create_trimesh_shape()
	static_body.add_child(collision_shape)
	add_child(static_body)
