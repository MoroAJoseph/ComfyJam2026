class_name VoxelEngineContexualCubeChunk
extends StaticBody3D

enum Face { FRONT, BACK, LEFT, RIGHT, TOP, BOTTOM }

@export var use_debug_colors: bool = false
@export var material: Material

@onready var mesh_instance: MeshInstance3D = $MeshInstance

var surface_array: Array = []
var voxels: PackedByteArray
var prepared_vertices: PackedVector3Array
var prepared_normals: PackedVector3Array
var prepared_colors: PackedColorArray
var body_rid: RID
var shape_rid: RID

static var cube_vertices: Array[Vector3] = [
	Vector3(-0.5, -0.5, 0.5), Vector3(0.5, -0.5, 0.5),
	Vector3(0.5, -0.5, -0.5), Vector3(-0.5, -0.5, -0.5),
	Vector3(-0.5, 0.5, 0.5), Vector3(0.5, 0.5, 0.5),
	Vector3(0.5, 0.5, -0.5), Vector3(-0.5, 0.5, -0.5)
]

static var face_indices: Dictionary[Face, Array] = {
	Face.FRONT: [[0, 4, 5], [0, 5, 1]],
	Face.BACK: [[2, 7, 3], [2, 6, 7]],
	Face.LEFT: [[3, 7, 4], [3, 4, 0]],
	Face.RIGHT: [[1, 5, 6], [1, 6, 2]],
	Face.TOP: [[0, 1, 2], [0, 2, 3]],
	Face.BOTTOM: [[4, 7, 6], [4, 6, 5]]
}

static var face_normals: Dictionary[Face, Vector3] = {
	Face.FRONT: Vector3(0, 0, 1), Face.BACK: Vector3(0, 0, -1),
	Face.LEFT: Vector3(-1, 0, 0), Face.RIGHT: Vector3(1, 0, 0),
	Face.TOP: Vector3(0, -1, 0), Face.BOTTOM: Vector3(0, 1, 0)
}

static var debug_colors: Dictionary[Face, Color] = {
	Face.FRONT: Color.ORANGE, Face.BACK: Color.PURPLE,
	Face.LEFT: Color.BLUE, Face.RIGHT: Color.YELLOW,
	Face.TOP: Color.GREEN, Face.BOTTOM: Color.RED
}


func _ready() -> void:
	surface_array.resize(Mesh.ARRAY_MAX)
	mesh_instance.mesh = ArrayMesh.new()

func get_idx(x: int, y: int, z: int, size: int) -> int:
	return x + size * (y + size * z)

func generate_mesh(size: int, max_height: int, noise: Noise, colors: Array[Color], origin: Vector3) -> PackedByteArray:
	voxels.resize(size * size * size)
	voxels.fill(0)
	
	for x in range(size):
		for z in range(size):
			var global_pos := Vector2(x + origin.x, z + origin.z)
			var rand = (
				(
					noise.get_noise_2d(global_pos.x, global_pos.y) + 
					0.5 * 
					noise.get_noise_2d(global_pos.x * 2, global_pos.y * 2) + 
					0.25 * 
					noise.get_noise_2d(global_pos.x * 4, global_pos.y * 4)
				) / 1.75 + 1
			) / 2
			var rand_p = pow(rand, 2.1)
			var height = max_height * rand_p
			
			if height < origin.y: continue
			
			var loca_height = height - origin.y
			
			for y in range(min(loca_height, size)):
				var idx = x + (y * size) + (z * size * size)
				voxels[idx] = (y % colors.size()) + 1 # +1 to avoid 0 (air)
	
	return voxels

# CRITICAL: THREAD-SAFE: Calculates geometry without touching the SceneTree
func prepare_mesh_data(coords: Vector3i, registry: Dictionary, size: int, colors: Array[Color]) -> int:
	var visible_block_count = 0
	
	prepared_vertices = PackedVector3Array()
	prepared_normals = PackedVector3Array()
	prepared_colors = PackedColorArray()
	
	for x in range(size):
		for y in range(size):
			for z in range(size):
				var idx = get_idx(x, y, z, size)
				if voxels[idx] == 0: continue
				
				var old_count = prepared_vertices.size()
				
				# Check neighbors (Unrolled for speed)
				check_and_add_face(x, y, z, Vector3(0,0,1), Face.FRONT, coords, registry, size, colors[voxels[idx]-1])
				check_and_add_face(x, y, z, Vector3(0,0,-1), Face.BACK, coords, registry, size, colors[voxels[idx]-1])
				check_and_add_face(x, y, z, Vector3(-1,0,0), Face.LEFT, coords, registry, size, colors[voxels[idx]-1])
				check_and_add_face(x, y, z, Vector3(1,0,0), Face.RIGHT, coords, registry, size, colors[voxels[idx]-1])
				check_and_add_face(x, y, z, Vector3(0,-1,0), Face.TOP, coords, registry, size, colors[voxels[idx]-1])
				check_and_add_face(x, y, z, Vector3(0,1,0), Face.BOTTOM, coords, registry, size, colors[voxels[idx]-1])
				
				if prepared_vertices.size() > old_count:
					visible_block_count += 1
	
	return visible_block_count

func check_and_add_face(x, y, z, norm, face, coords, registry, size, color):
	var nx = x + norm.x
	var ny = y + norm.y
	var nz = z + norm.z
	var is_shown = false
	
	# Internal check
	if nx >= 0 and nx < size and ny >= 0 and ny < size and nz >= 0 and nz < size:
		is_shown = voxels[get_idx(nx, ny, nz, size)] == 0
	else:
		var n_coords = coords + Vector3i(norm)
		if registry.has(n_coords):
			var neighbor_voxels = registry[n_coords]
			# Safety: Ensure neighbor exists AND is the correct size
			if neighbor_voxels != null and neighbor_voxels.size() == (size * size * size):
				var n_idx = get_idx(posmod(nx, size), posmod(ny, size), posmod(nz, size), size)
				# CRITICAL: Add explicit bounds check
				if n_idx >= 0 and n_idx < neighbor_voxels.size():
					is_shown = neighbor_voxels[n_idx] == 0
				else:
					is_shown = true 
			else:
				is_shown = true 
		else:
			is_shown = true 
			
	if is_shown: add_face_to_prepared(face, Vector3(x, y, z), color)

func add_face_to_prepared(face: Face, pos: Vector3, color: Color) -> void:
	var indices = face_indices[face]
	for triangle in indices:
		for index in triangle:
			prepared_vertices.append(cube_vertices[index] + pos)
			prepared_normals.append(face_normals[face])
			prepared_colors.append(debug_colors[face] if use_debug_colors else color)

# CRITICAL: MAIN THREAD ONLY: Finalizes the mesh on the GPU
func apply_prepared_mesh() -> void:
	if prepared_vertices.is_empty():
		mesh_instance.mesh.clear_surfaces()
		return

	mesh_instance.mesh.clear_surfaces()

	surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	surface_array[Mesh.ARRAY_VERTEX] = prepared_vertices
	surface_array[Mesh.ARRAY_NORMAL] = prepared_normals
	surface_array[Mesh.ARRAY_COLOR] = prepared_colors

	mesh_instance.mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		surface_array
	)

	if material:
		mesh_instance.set_surface_override_material(0, material)

# CRITICAL: MAIN THREAD ONLY
func apply_collision(verts: PackedVector3Array) -> void:
	if body_rid.is_valid(): 
		PhysicsServer3D.free_rid(body_rid)
		PhysicsServer3D.free_rid(shape_rid)
		
	body_rid = PhysicsServer3D.body_create()
	shape_rid = PhysicsServer3D.concave_polygon_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid, {"faces": verts, "backface_collision": false})
	PhysicsServer3D.body_add_shape(body_rid, shape_rid)
	PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
	PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, global_transform)

# IMPORTANT: Always clean up server resources when the node is freed
func _exit_tree() -> void:
	if body_rid.is_valid():
		PhysicsServer3D.free_rid(body_rid)
	if shape_rid.is_valid():
		PhysicsServer3D.free_rid(shape_rid)

func apply_geometry(geo: Dictionary) -> void:
	if geo.verts.is_empty(): 
		mesh_instance.mesh.clear_surfaces()
		return

	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = geo.verts
	arr[Mesh.ARRAY_NORMAL] = geo.norms
	arr[Mesh.ARRAY_COLOR] = geo.cols
	
	var am = ArrayMesh.new()
	am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	mesh_instance.mesh = am
	
	if material:
		mesh_instance.set_surface_override_material(0, material)
