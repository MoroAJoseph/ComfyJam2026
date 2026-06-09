class_name VoxelEngineHexagon 
extends VoxelEngineVoxel

const FACE_TO_NEIGHBOR: Array[Vector3i] = [
	Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(-1, 0, 1),
	Vector3i(-1, 0, 0), Vector3i(0, 0, -1), Vector3i(1, 0, -1)
]

static func get_single_voxel_geometry(voxel: Vector3i, data: PackedByteArray, coords: Vector3i, registry: Dictionary, size: int, color: Color) -> Dictionary:
	var verts := PackedVector3Array(); var norms := PackedVector3Array(); var cols := PackedColorArray(); var uvs := PackedVector2Array()
	var s := 1.0; var h := 1.0
	var center := _get_hex_world_pos(voxel, s, h)
	var base := _get_hex_points(center, s, -h / 2.0)
	var top := _get_hex_points(center, s, h / 2.0)

	if _is_air(voxel.x, voxel.y + 1, voxel.z, data, coords, registry, size): _add_cap(top, true, color, verts, norms, cols)
	if _is_air(voxel.x, voxel.y - 1, voxel.z, data, coords, registry, size): _add_cap(base, false, color, verts, norms, cols)

	for i in range(6):
		var offset := FACE_TO_NEIGHBOR[i]
		if _is_air(voxel.x + offset.x, voxel.y + offset.y, voxel.z + offset.z, data, coords, registry, size):
			var next := (i + 1) % 6
			var normal := (base[i] + base[next] - (center * 2.0)).normalized()
			normal.y = 0.0
			_add_side(base[i], base[next], top[next], top[i], normal, color, verts, norms, cols)
	return {"verts": verts, "norms": norms, "cols": cols, "uvs": uvs}

static func calculate_geometry(
	data: PackedByteArray, 
	coords: Vector3i, 
	registry: Dictionary, 
	size: int, 
	colors: Array[Color]
) -> Dictionary:
	var v := PackedVector3Array()
	var n := PackedVector3Array()
	var c := PackedColorArray()
	var u := PackedVector2Array()
	
	for x in range(size):
		for y in range(size):
			for z in range(size):
				var index := get_index(x, y, z, size)
				if data[index] == 0: continue
				var col := colors[data[index] - 1]
				var center := _get_hex_world_pos(Vector3i(x, y, z), 1.0, 1.0)
				var base := _get_hex_points(center, 1.0, -0.5)
				var top := _get_hex_points(center, 1.0, 0.5)
				if _is_air(x, y + 1, z, data, coords, registry, size): _add_cap(top, true, col, v, n, c)
				if _is_air(x, y - 1, z, data, coords, registry, size): _add_cap(base, false, col, v, n, c)
				for i in range(6):
					var offset := FACE_TO_NEIGHBOR[i]
					if _is_air(x + offset.x, y + offset.y, z + offset.z, data, coords, registry, size):
						var next := (i + 1) % 6
						var normal := (base[i] + base[next] - (center * 2.0)).normalized()
						normal.y = 0.0
						_add_side(base[i], base[next], top[next], top[i], normal, col, v, n, c)
	return {"verts": v, "norms": n, "cols": c, "uvs": u}


static func get_noise_coords(x: int, z: int, world_origin: Vector3) -> Vector2:
	var offset_x: float = 1.5 * float(x)
	var offset_z: float = sqrt(3.0) * (float(z) + 0.5 * float(x))
	
	return Vector2(world_origin.x + offset_x, world_origin.z + offset_z)

static func normal_to_hex_dir(n: Vector3) -> int:
	var dirs := FACE_TO_NEIGHBOR

	var best := 0
	var best_dot := -INF

	for i in range(6):
		var d := Vector3(dirs[i]).normalized()
		var dot := n.normalized().dot(d)

		if dot > best_dot:
			best_dot = dot
			best = i

	return best

static func world_to_local(world_pos: Vector3, chunk_origin: Vector3) -> Vector3i:
	var rel := world_pos - chunk_origin
	var s := 1.0 
	var x_f := (rel.x - 0.5 * s) / (1.5 * s)
	var z_f := (rel.z - 0.5 * s) / (sqrt(3.0) * s) - (0.5 * x_f)
	return Vector3i(roundi(x_f), floori((rel.y - 0.5) / 1.0), roundi(z_f))

static func world_to_chunk(world_pos: Vector3, chunk_size: int) -> Vector3i:
	var s := float(chunk_size)
	var cx := roundi(world_pos.x / (s * 1.5))
	var cz := roundi((world_pos.z / (s * sqrt(3.0))) - (0.5 * cx))
	return Vector3i(cx, 0, cz)

static func chunk_to_world(coord: Vector3i, size: int) -> Vector3:
	var s := float(size)
	return Vector3(s * 1.5 * coord.x, 0, s * sqrt(3.0) * (coord.z + coord.x * 0.5))

static func voxel_to_world(voxel: Vector3i) -> Vector3:
	var s := 1.0
	var h := 1.0
	return _get_hex_world_pos(voxel, s, h)

# ===
# Private
# ===

static func _is_air(x: int, y: int, z: int, local: PackedByteArray, coords: Vector3i, registry: Dictionary, size: int) -> bool:
	if x >= 0 and x < size and y >= 0 and y < size and z >= 0 and z < size:
		return local[x + y * size + z * size * size] == 0
	
	var neighbor_coords: Vector3i = coords
	var nx: int = x
	var ny: int = y
	var nz: int = z
	
	while nx < 0: neighbor_coords.x -= 1; nx += size
	while nx >= size: neighbor_coords.x += 1; nx -= size
	while nz < 0: neighbor_coords.z -= 1; nz += size
	while nz >= size: neighbor_coords.z += 1; nz -= size
	while ny < 0: neighbor_coords.y -= 1; ny += size
	while ny >= size: neighbor_coords.y += 1; ny -= size
	
	if not registry.has(neighbor_coords):
		return true
	return registry[neighbor_coords][nx + ny * size + nz * size * size] == 0

static func _get_hex_world_pos(pos: Vector3i, s: float, h: float) -> Vector3:
	return Vector3(
		s * (1.5 * float(pos.x)) + s * 0.5,
		float(pos.y) * h + h * 0.5,
		s * (sqrt(3.0) * (float(pos.z) + 0.5 * float(pos.x))) + s * 0.5
	)

static func _get_hex_points(center: Vector3, s: float, y_off: float) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for i: int in range(6):
		var angle: float = deg_to_rad(60.0 * float(i))
		points.append(center + Vector3(cos(angle) * s, y_off, sin(angle) * s))
	return points

static func _add_side(p1, p2, p3, p4, n, _c, v, no, co) -> void:
	# Flag: BLUE for sides
	var face_color = Color(0, 0, 1, 1) 
	_add_tri(p1, p2, p3, n, face_color, v, no, co)
	_add_tri(p1, p3, p4, n, face_color, v, no, co)

static func _add_cap(points: Array[Vector3], is_top: bool, _c: Color, v: PackedVector3Array, no: PackedVector3Array, co: PackedColorArray) -> void:
	var center = Vector3.ZERO
	for p in points: center += p
	center /= 6.0
	# Flag: RED for Top, GREEN for Bottom
	var face_color = Color(1, 0, 0, 1) if is_top else Color(0, 1, 0, 1)
	var n = Vector3.UP if is_top else Vector3.DOWN
	
	for i in range(6):
		var next = (i + 1) % 6
		if is_top: _add_tri(center, points[i], points[next], n, face_color, v, no, co)
		else: _add_tri(center, points[next], points[i], n, face_color, v, no, co)

static func _add_tri(p1: Vector3, p2: Vector3, p3: Vector3, n: Vector3, c: Color, v: PackedVector3Array, no: PackedVector3Array, co: PackedColorArray, _uvs: PackedVector2Array = PackedVector2Array()) -> void:
	v.append_array([p1, p2, p3])
	# n is the face normal. Append it 3 times to ensure the shader sees flat faces
	no.append_array([n, n, n]) 
	co.append_array([c, c, c])
