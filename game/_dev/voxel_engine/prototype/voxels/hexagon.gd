class_name VoxelEngineHexagon extends VoxelEngineVoxel

const FACE_TO_NEIGHBOR: Array[Vector3i] = [
	Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(-1, 0, 1),
	Vector3i(-1, 0, 0), Vector3i(0, 0, -1), Vector3i(1, 0, -1)
]

static func calculate_geometry(data: PackedByteArray, coords: Vector3i, registry: Dictionary, size: int, colors: Array[Color]) -> Dictionary:
	var vertices_out: PackedVector3Array = PackedVector3Array()
	var normals_out: PackedVector3Array = PackedVector3Array()
	var colors_out: PackedColorArray = PackedColorArray()
	var hex_size: float = 1.0
	var hex_height: float = 1.0

	for x: int in range(size):
		for y: int in range(size):
			for z: int in range(size):
				var index: int = x + y * size + z * size * size
				if data[index] == 0:
					continue
				
				var color: Color = colors[data[index] - 1]
				var center_pos: Vector3 = _get_hex_world_pos(Vector3i(x, y, z), hex_size, hex_height)
				var base_points: Array[Vector3] = _get_hex_points(center_pos, hex_size, -hex_height / 2.0)
				var top_points: Array[Vector3] = _get_hex_points(center_pos, hex_size, hex_height / 2.0)

				if _is_air(x, y + 1, z, data, coords, registry, size):
					_add_cap(top_points, true, color, vertices_out, normals_out, colors_out)
				if _is_air(x, y - 1, z, data, coords, registry, size):
					_add_cap(base_points, false, color, vertices_out, normals_out, colors_out)

				for i: int in range(6):
					var offset: Vector3i = FACE_TO_NEIGHBOR[i]
					if _is_air(x + offset.x, y + offset.y, z + offset.z, data, coords, registry, size):
						var next: int = (i + 1) % 6
						var normal: Vector3 = (base_points[i] + base_points[next] - (center_pos * 2.0)).normalized()
						normal.y = 0.0
						_add_side(base_points[i], base_points[next], top_points[next], top_points[i], normal, color, vertices_out, normals_out, colors_out)
	return {"verts": vertices_out, "norms": normals_out, "cols": colors_out}

static func get_noise_coords(x: int, z: int, world_origin: Vector3) -> Vector2:
	var offset_x: float = 1.5 * float(x)
	var offset_z: float = sqrt(3.0) * (float(z) + 0.5 * float(x))
	
	return Vector2(world_origin.x + offset_x, world_origin.z + offset_z)

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
	return Vector3(s * (1.5 * float(pos.x)), float(pos.y) * h, s * (sqrt(3.0) * (float(pos.z) + 0.5 * float(pos.x))))

static func _get_hex_points(center: Vector3, s: float, y_off: float) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for i: int in range(6):
		var angle: float = deg_to_rad(60.0 * float(i))
		points.append(center + Vector3(cos(angle) * s, y_off, sin(angle) * s))
	return points

static func _add_side(p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3, n: Vector3, c: Color, v: PackedVector3Array, no: PackedVector3Array, co: PackedColorArray) -> void:
	_add_tri(p1, p2, p3, n, c, v, no, co)
	_add_tri(p1, p3, p4, n, c, v, no, co)

static func _add_cap(points: Array[Vector3], is_top: bool, c: Color, v: PackedVector3Array, no: PackedVector3Array, co: PackedColorArray) -> void:
	var center: Vector3 = Vector3.ZERO
	for p: Vector3 in points: center += p
	center /= 6.0
	var n: Vector3 = Vector3.UP if is_top else Vector3.DOWN
	for i: int in range(6):
		var next: int = (i + 1) % 6
		if is_top:
			_add_tri(center, points[i], points[next], n, c, v, no, co)
		else:
			_add_tri(center, points[next], points[i], n, c, v, no, co)

static func _add_tri(p1: Vector3, p2: Vector3, p3: Vector3, n: Vector3, c: Color, v: PackedVector3Array, no: PackedVector3Array, co: PackedColorArray) -> void:
	v.append_array([p1, p2, p3])
	for i: int in range(3):
		no.append(n)
		co.append(c)
