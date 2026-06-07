class_name VoxelEngineContexualHexagonChunk
extends StaticBody3D

@export var use_rendering_server: bool = true
@export var use_physics_server: bool = false
@export var use_debug_colors: bool = false
@export var material: Material

@onready var mesh_instance: MeshInstance3D = $MeshInstance

var prepared_vertices: PackedVector3Array
var prepared_normals: PackedVector3Array
var prepared_colors: PackedColorArray

var surface_array: Array = []
var voxels: PackedByteArray
var mesh_rid: RID
var instance_rid: RID
var body_rid: RID
var shape_rid: RID

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
	surface_array.resize(Mesh.ARRAY_MAX)
	mesh_rid = RenderingServer.mesh_create()
	instance_rid = RenderingServer.instance_create()

func _ready() -> void:
	mesh_instance.mesh = ArrayMesh.new()

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

# --- THREAD-SAFE GENERATION ---
func prepare_mesh_data(coords: Vector3i, registry: Dictionary, size: int, colors: Array[Color]) -> int:
	var visible_block_count = 0
	
	prepared_vertices = PackedVector3Array()
	prepared_normals = PackedVector3Array()
	prepared_colors = PackedColorArray()
	
	var local_voxels = registry[coords]
	
	var h_size = 1.0
	var h_height = 1.0
	
	# Iterate through local voxels
	for x in range(size):
		for y in range(size):
			for z in range(size):
				var idx = x + (y * size) + (z * size * size)
				if local_voxels[idx] == 0: continue
				
				var color = colors[local_voxels[idx] - 1]
				var center_v3 = _get_hex_world_pos(Vector3i(x, y, z), h_size, h_height)
				var base_points = _get_hex_points(center_v3, h_size, -h_height / 2.0)
				var top_points = _get_hex_points(center_v3, h_size, h_height / 2.0)

				# Cull vertical neighbors (Using registry/local logic)
				if _is_air(x, y + 1, z, local_voxels, coords, registry, size):
					_add_cap_prepared(top_points, true, color)
				if _is_air(x, y - 1, z, local_voxels, coords, registry, size):
					_add_cap_prepared(base_points, false, color)

				# Cull side neighbors
				for i in range(6):
					var offset = FACE_TO_NEIGHBOR_MAP[i]
					if _is_air(x + offset.x, y + offset.y, z + offset.z, local_voxels, coords, registry, size):
						var next = (i + 1) % 6
						var normal = (base_points[i] + base_points[next] - (center_v3 * 2.0)).normalized()
						normal.y = 0
						_add_side_prepared(base_points[i], base_points[next], top_points[next], top_points[i], normal, color)
				
				visible_block_count += 1
	
	return visible_block_count

func _is_air(
	x: int,
	y: int,
	z: int,
	local_voxels: PackedByteArray,
	coords: Vector3i,
	registry: Dictionary,
	size: int
) -> bool:

	# Local lookup
	if x >= 0 and x < size and y >= 0 and y < size and z >= 0 and z < size:
		return local_voxels[x + y * size + z * size * size] == 0

	var neighbor_chunk := coords

	var nx := x
	var ny := y
	var nz := z

	# X crossing
	while nx < 0:
		neighbor_chunk.x -= 1
		nx += size

	while nx >= size:
		neighbor_chunk.x += 1
		nx -= size

	# Z crossing
	while nz < 0:
		neighbor_chunk.z -= 1
		nz += size

	while nz >= size:
		neighbor_chunk.z += 1
		nz -= size

	# Y crossing
	while ny < 0:
		neighbor_chunk.y -= 1
		ny += size

	while ny >= size:
		neighbor_chunk.y += 1
		ny -= size

	if !registry.has(neighbor_chunk):
		return true

	var n_voxels: PackedByteArray = registry[neighbor_chunk]

	return n_voxels[
		nx +
		ny * size +
		nz * size * size
	] == 0

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
	if prepared_vertices.is_empty():
		return
	surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = prepared_vertices
	surface_array[Mesh.ARRAY_NORMAL] = prepared_normals
	surface_array[Mesh.ARRAY_COLOR] = prepared_colors
	
	mesh_instance.mesh.clear_surfaces()
	mesh_instance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	if material: mesh_instance.set_surface_override_material(0, material)

func apply_collision() -> void:
	# Cleanup old physics objects if they exist
	if body_rid.is_valid(): PhysicsServer3D.free_rid(body_rid)
	if shape_rid.is_valid(): PhysicsServer3D.free_rid(shape_rid)
	
	body_rid = PhysicsServer3D.body_create()
	PhysicsServer3D.body_set_mode(body_rid, PhysicsServer3D.BODY_MODE_STATIC)
	
	shape_rid = PhysicsServer3D.concave_polygon_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid, {"faces": prepared_vertices, "backface_collision": false})
	
	PhysicsServer3D.body_add_shape(body_rid, shape_rid)
	PhysicsServer3D.body_set_space(body_rid, get_world_3d().space)
	PhysicsServer3D.body_set_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, global_transform)

func _exit_tree() -> void:
	# Cleanup Rendering Server
	if use_rendering_server:
		RenderingServer.free_rid(instance_rid)
		RenderingServer.free_rid(mesh_rid)
		
	# Cleanup Physics Server
	if body_rid.is_valid():
		PhysicsServer3D.free_rid(body_rid)
	if shape_rid.is_valid():
		PhysicsServer3D.free_rid(shape_rid)
		
	# Decrement telemetry in Manager if needed
	var manager = get_parent()
	if manager and "total_collision_shapes" in manager:
		manager.total_collision_shapes -= 1
