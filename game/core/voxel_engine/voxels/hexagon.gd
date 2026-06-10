class_name VoxelEngineHexagon
extends VoxelEngineVoxel

## Neighbors for a hex grid in axial coordinate space.
const FACE_TO_NEIGHBOR: Array[Vector3i] = [
	Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(-1, 0, 1),
	Vector3i(-1, 0, 0), Vector3i(0, 0, -1), Vector3i(1, 0, -1)
]

## Debug utility for verifying chunk alignment.
static func debug_chunk_alignment(size: int) -> void:
	print("Last voxel X chunk:")
	print(_get_hex_world_position(Vector3i(size - 1, 0, 0), 1.0, 1.0))

	print("Next chunk origin X:")
	print(chunk_to_world(Vector3i(1, 0, 0), size))

	print("Last voxel Z chunk:")
	print(_get_hex_world_position(Vector3i(0, 0, size - 1), 1.0, 1.0))

	print("Next chunk origin Z:")
	print(chunk_to_world(Vector3i(0, 0, 1), size))

## Generates geometry for a single hexagonal voxel.
static func get_single_voxel_geometry(
	voxel: Vector3i,
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	size: int,
	color: Color
) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	var uvs := PackedVector2Array()
	
	var scale := 1.0
	var height := 1.0
	var center := Vector3.ZERO
	
	var base_points := _get_hex_points(center, scale, -height / 2.0)
	var top_points := _get_hex_points(center, scale, height / 2.0)

	if _is_air(voxel.x, voxel.y + 1, voxel.z, data, coordinates, registry, size):
		_add_cap(top_points, true, color, vertices, normals, colors)
	if _is_air(voxel.x, voxel.y - 1, voxel.z, data, coordinates, registry, size):
		_add_cap(base_points, false, color, vertices, normals, colors)

	for index in range(6):
		var offset: Vector3i = FACE_TO_NEIGHBOR[index]
		if _is_air(voxel.x + offset.x, voxel.y + offset.y, voxel.z + offset.z, data, coordinates, registry, size):
			var next_index := (index + 1) % 6
			var normal := (base_points[index] + base_points[next_index] - (center * 2.0)).normalized()
			normal.y = 0.0
			_add_side(base_points[index], base_points[next_index], top_points[next_index], top_points[index], normal, color, vertices, normals, colors)
	
	return {"vertices": vertices, "normals": normals, "colors": colors, "uvs": uvs}

## Builds the mesh geometry for an entire chunk of hexagonal voxels.
static func calculate_geometry(
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	size: int,
	colors: Array[Color]
) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var color_array := PackedColorArray()
	var uvs := PackedVector2Array()
	
	for x in range(size):
		for y in range(size):
			for z in range(size):
				var index := get_index(x, y, z, size)
				if data[index] == 0:
					continue
				
				var voxel_color := colors[data[index] - 1]
				var center := Vector3(
					1.5 * float(x),
					float(y),
					sqrt(3.0) * (float(z) + 0.5 * float(x))
				)
				var base_points := _get_hex_points(center, 1.0, -0.5)
				var top_points := _get_hex_points(center, 1.0, 0.5)
				
				if _is_air(x, y + 1, z, data, coordinates, registry, size):
					_add_cap(top_points, true, voxel_color, vertices, normals, color_array)
				if _is_air(x, y - 1, z, data, coordinates, registry, size):
					_add_cap(base_points, false, voxel_color, vertices, normals, color_array)
					
				for i in range(6):
					var offset: Vector3i = FACE_TO_NEIGHBOR[i]
					if _is_air(x + offset.x, y + offset.y, z + offset.z, data, coordinates, registry, size):
						var next_index := (i + 1) % 6
						var normal := (base_points[i] + base_points[next_index] - (center * 2.0)).normalized()
						normal.y = 0.0
						_add_side(base_points[i], base_points[next_index], top_points[next_index], top_points[i], normal, voxel_color, vertices, normals, color_array)
	
	return {
		"vertices": vertices, 
		"normals": normals, 
		"colors": color_array, 
		"uvs": uvs
	}

## Calculates noise sampling coordinates.
static func get_noise_coordinates(x: int, z: int, world_origin: Vector3) -> Vector2:
	var offset_x: float = 1.5 * float(x)
	var offset_z: float = sqrt(3.0) * (float(z) + 0.5 * float(x))
	return Vector2(world_origin.x + offset_x, world_origin.z + offset_z)

## Maps a normal vector to the nearest hexagonal face direction.
static func normal_to_hex_direction(normal: Vector3) -> int:
	var directions := FACE_TO_NEIGHBOR
	var best_index := 0
	var best_dot := -INF

	for i in range(6):
		var direction := Vector3(directions[i]).normalized()
		var dot := normal.normalized().dot(direction)

		if dot > best_dot:
			best_dot = dot
			best_index = i
	return best_index

## Converts world-space position into local hexagonal voxel coordinates.
static func world_to_local(world_position: Vector3, chunk_origin: Vector3) -> Vector3i:
	var relative_position := world_position - chunk_origin
	
	var axial_q := relative_position.x / 1.5
	var axial_r := (relative_position.z / sqrt(3.0)) - (0.5 * axial_q)
	
	var cube_x := axial_q
	var cube_z := axial_r
	var cube_y := -cube_x - cube_z
	
	var round_x = round(cube_x)
	var round_y = round(cube_y)
	var round_z = round(cube_z)
	
	var diff_x = abs(round_x - cube_x)
	var diff_y = abs(round_y - cube_y)
	var diff_z = abs(round_z - cube_z)
	
	if diff_x > diff_y and diff_x > diff_z:
		round_x = -round_y - round_z
	elif diff_y > diff_z:
		round_y = -round_x - round_z
	else:
		round_z = -round_x - round_y
		
	return Vector3i(int(round_x), roundi(relative_position.y), int(round_z))

## Maps world-space position to its chunk coordinate.
static func world_to_chunk(world_position: Vector3, chunk_size: int) -> Vector3i:
	var q := (2.0 / 3.0) * world_position.x
	var r := ((-1.0 / 3.0) * world_position.x + (world_position.z / sqrt(3.0)))
	return Vector3i(floori(q / float(chunk_size)), 0, floori(r / float(chunk_size)))

## Converts chunk coordinates to world-space.
static func chunk_to_world(coordinate: Vector3i, size: int) -> Vector3:
	return _get_hex_world_position(Vector3i(coordinate.x * size, 0, coordinate.z * size), 1.0, 1.0)

## Converts a voxel coordinate to world-space.
static func voxel_to_world(voxel: Vector3i, chunk_origin: Vector3) -> Vector3:
	return _get_hex_world_position(voxel, 1.0, 1.0) + chunk_origin

# === Private Helpers ===

static func _is_air(x: int, y: int, z: int, local_data: PackedByteArray, coordinates: Vector3i, registry: Dictionary, size: int) -> bool:
	if x >= 0 and x < size and y >= 0 and y < size and z >= 0 and z < size:
		return local_data[x + y * size + z * size * size] == 0
	
	var neighbor_coordinates := coordinates
	var nx := x
	var ny := y
	var nz := z

	while nx < 0: neighbor_coordinates.x -= 1; nx += size
	while nx >= size: neighbor_coordinates.x += 1; nx -= size
	while ny < 0: neighbor_coordinates.y -= 1; ny += size
	while ny >= size: neighbor_coordinates.y += 1; ny -= size
	while nz < 0: neighbor_coordinates.z -= 1; nz += size
	while nz >= size: neighbor_coordinates.z += 1; nz -= size
	
	var chunk = registry.get(neighbor_coordinates)
	if not chunk is PackedByteArray:
		return true
		
	return chunk[nx + ny * size + nz * size * size] == 0

static func _get_hex_world_position(position: Vector3i, scale: float, height: float) -> Vector3:
	return Vector3(
		scale * (1.5 * float(position.x)),
		float(position.y) * height,
		scale * (sqrt(3.0) * (float(position.z) + 0.5 * float(position.x)))
	)

static func _get_hex_points(center: Vector3, scale: float, y_offset: float) -> Array[Vector3]:
	var points: Array[Vector3] = []
	for i in range(6):
		var angle: float = deg_to_rad(60.0 * float(i))
		points.append(center + Vector3(cos(angle) * scale, y_offset, sin(angle) * scale))
	return points

static func _add_side(p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3, normal: Vector3, _color: Color, vertices: PackedVector3Array, normals: PackedVector3Array, colors: PackedColorArray) -> void:
	var face_color := Color(0, 0, 1, 1) 
	add_triangle(p1, p2, p3, normal, face_color, vertices, normals, colors)
	add_triangle(p1, p3, p4, normal, face_color, vertices, normals, colors)

static func _add_cap(points: Array[Vector3], is_top: bool, _color: Color, vertices: PackedVector3Array, normals: PackedVector3Array, colors: PackedColorArray) -> void:
	var center := Vector3.ZERO
	for point in points: center += point
	center /= 6.0
	
	var face_color := Color(1, 0, 0, 1) if is_top else Color(0, 1, 0, 1)
	var normal := Vector3.UP if is_top else Vector3.DOWN
	
	for i in range(6):
		var next := (i + 1) % 6
		if is_top:
			add_triangle(center, points[i], points[next], normal, face_color, vertices, normals, colors)
		else:
			add_triangle(center, points[next], points[i], normal, face_color, vertices, normals, colors)
