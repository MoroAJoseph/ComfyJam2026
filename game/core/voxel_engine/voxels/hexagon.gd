class_name VoxelEngineHexagon
extends VoxelEngineVoxel



## Generates geometry for a single hexagonal voxel.
static func get_single_voxel_geometry(
	voxel: Vector3i,
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	size: int,
	colors: PackedColorArray
) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var result_colors := PackedColorArray()
	var uvs := PackedVector2Array()
	
	var voxel_color = colors[0] if not colors.is_empty() else Color.WHITE
	var scale := 1.0
	var height := 1.0
	var center := Vector3.ZERO
	
	var base_points := _get_hex_points(center, scale, -height / 2.0)
	var top_points := _get_hex_points(center, scale, height / 2.0)

	if _is_air(voxel.x, voxel.y + 1, voxel.z, data, coordinates, registry, size):
		_add_cap(top_points, true, voxel_color, vertices, normals, result_colors)
	if _is_air(voxel.x, voxel.y - 1, voxel.z, data, coordinates, registry, size):
		_add_cap(base_points, false, voxel_color, vertices, normals, result_colors)

	for index in range(6):
		var offset: Vector3i = VoxelEngineConstants.Hexagon.FACE_TO_NEIGHBOR[index]
		if _is_air(voxel.x + offset.x, voxel.y + offset.y, voxel.z + offset.z, data, coordinates, registry, size):
			var next_index: int = (index + 1) % 6
			var normal := (base_points[index] + base_points[next_index] - (center * 2.0)).normalized()
			normal.y = 0.0
			_add_side(base_points[index], base_points[next_index], top_points[next_index], top_points[index], normal, voxel_color, vertices, normals, result_colors)
	
	return {
		"vertices": vertices, 
		"normals": normals, 
		"colors": result_colors, 
		"uvs": uvs
	}

static func get_single_textured_voxel_geometry(block_type: int) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var tangents := PackedFloat32Array()
	var uvs := PackedVector2Array()
	
	var tex_id: int = VoxelEngineConstants.BLOCK_TO_TEXTURE_INDEX.get(block_type, 0)
	var center := Vector3.ZERO
	var base_points := _get_hex_points(center, 1.0, -0.5)
	var top_points := _get_hex_points(center, 1.0, 0.5)

	# For a dropped item, we render all faces
	_add_textured_cap(top_points, true, tex_id, vertices, normals, tangents, uvs)
	_add_textured_cap(base_points, false, tex_id, vertices, normals, tangents, uvs)
	
	for i in range(6):
		var next_idx := (i + 1) % 6
		var normal := (base_points[i] + base_points[next_idx] - (center * 2.0)).normalized()
		normal.y = 0.0
		_add_textured_side(base_points[i], base_points[next_idx], top_points[next_idx], top_points[i], normal, tex_id, vertices, normals, tangents, uvs)
	
	return {
		"vertices": vertices, 
		"normals": normals, 
		"tangents": tangents,
		"uvs": uvs
	}

## Builds the mesh geometry for an entire chunk of hexagonal voxels.
static func calculate_geometry(
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	chunk_size: int,
	colors: PackedColorArray
) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			for z in range(chunk_size):
				var index := get_index(x, y, z, chunk_size)
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
				
				if _is_air(x, y + 1, z, data, coordinates, registry, chunk_size):
					_add_cap(top_points, true, voxel_color, vertices, normals, colors)
				if _is_air(x, y - 1, z, data, coordinates, registry, chunk_size):
					_add_cap(base_points, false, voxel_color, vertices, normals, colors)
					
				for i in range(6):
					var offset: Vector3i = VoxelEngineConstants.Hexagon.FACE_TO_NEIGHBOR[i]
					if _is_air(x + offset.x, y + offset.y, z + offset.z, data, coordinates, registry, chunk_size):
						var next_index := (i + 1) % 6
						var normal := (base_points[i] + base_points[next_index] - (center * 2.0)).normalized()
						normal.y = 0.0
						_add_side(base_points[i], base_points[next_index], top_points[next_index], top_points[i], normal, voxel_color, vertices, normals, colors)
	
	return {
		"vertices": vertices, 
		"normals": normals, 
		"colors": colors, 
		"uvs": uvs
	}

static func calculate_textured_geometry(
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	chunk_size: int,
) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var tangents := PackedFloat32Array()
	var uvs := PackedVector2Array()
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			for z in range(chunk_size):
				var index := get_index(x, y, z, chunk_size)
				var block_id = data[index]
				if block_id == 0: continue
				
				# LOOKUP: Map the Enum/ID to the Texture2DArray index (0, 1, or 2)
				var tex_id: int = VoxelEngineConstants.BLOCK_TO_TEXTURE_INDEX.get(block_id, 0)
				
				var center := Vector3(1.5 * float(x), float(y), sqrt(3.0) * (float(z) + 0.5 * float(x)))
				var base_points := _get_hex_points(center, 1.0, -0.5)
				var top_points := _get_hex_points(center, 1.0, 0.5)
				
				if _is_air(x, y + 1, z, data, coordinates, registry, chunk_size):
					_add_textured_cap(top_points, true, tex_id, vertices, normals, tangents, uvs)
				if _is_air(x, y - 1, z, data, coordinates, registry, chunk_size):
					_add_textured_cap(base_points, false, tex_id, vertices, normals, tangents, uvs)
					
				for i in range(6):
					var offset: Vector3i = VoxelEngineConstants.Hexagon.FACE_TO_NEIGHBOR[i]
					if _is_air(x + offset.x, y + offset.y, z + offset.z, data, coordinates, registry, chunk_size):
						var next_idx := (i + 1) % 6
						var normal := (base_points[i] + base_points[next_idx] - (center * 2.0)).normalized()
						normal.y = 0.0
						_add_textured_side(base_points[i], base_points[next_idx], top_points[next_idx], top_points[i], normal, tex_id, vertices, normals, tangents, uvs)
	
	return {
		"vertices": vertices, 
		"normals": normals, 
		"tangents": tangents,
		"uvs": uvs
	}

## Calculates noise sampling coordinates.
static func get_noise_coordinates(
	x: int, 
	z: int, 
	world_origin: Vector3
) -> Vector2:
	var offset_x: float = 1.5 * float(x)
	var offset_z: float = sqrt(3.0) * (float(z) + 0.5 * float(x))
	return Vector2(world_origin.x + offset_x, world_origin.z + offset_z)

## Maps a normal vector to the nearest hexagonal face direction.
static func normal_to_hex_direction(
	normal: Vector3
) -> int:
	var directions := VoxelEngineConstants.Hexagon.FACE_TO_NEIGHBOR
	var best_index: int = 0
	var best_dot: float = -INF

	for i in range(6):
		var direction := Vector3(directions[i]).normalized()
		var dot := normal.normalized().dot(direction)

		if dot > best_dot:
			best_dot = dot
			best_index = i
	return best_index

## Converts world-space position into local hexagonal voxel coordinates.
static func world_to_local(
	world_position: Vector3, 
	chunk_origin: Vector3
) -> Vector3i:
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
static func world_to_chunk(
	world_position: Vector3,
	chunk_size: int
) -> Vector3i:
	var q: float = (2.0 / 3.0) * world_position.x
	var r: float = ((-1.0 / 3.0) * world_position.x + (world_position.z / sqrt(3.0)))
	return Vector3i(
		floori(q / float(chunk_size)), 
		0, 
		floori(r / float(chunk_size))
	)

## Converts chunk coordinates to world-space.
static func chunk_to_world(
	coordinate: Vector3i, 
	size: int
) -> Vector3:
	return get_hex_world_position(
		Vector3i(
			coordinate.x * size, 
			0, 
			coordinate.z * size
		), 
		1.0, 
		1.0
	)

## Converts a voxel coordinate to world-space.
static func voxel_to_world(
	voxel: Vector3i, 
	chunk_origin: Vector3
) -> Vector3:
	return get_hex_world_position(voxel, 1.0, 1.0) + chunk_origin

# === Private Helpers ===

static func _is_air(
	x: int, 
	y: int, 
	z: int, 
	local_data: PackedByteArray, 
	coordinates: Vector3i, 
	registry: Dictionary, 
	chunk_size: int
) -> bool:
	if (
		x >= 0 and 
		x < chunk_size and 
		y >= 0 and 
		y < chunk_size and 
		z >= 0 and 
		z < chunk_size
	):
		return local_data[x + y * chunk_size + z * chunk_size * chunk_size] == 0
	
	var nx := x
	var ny := y
	var nz := z

	while nx < 0: coordinates.x -= 1; nx += chunk_size
	while nx >= chunk_size: coordinates.x += 1; nx -= chunk_size
	while ny < 0: coordinates.y -= 1; ny += chunk_size
	while ny >= chunk_size: coordinates.y += 1; ny -= chunk_size
	while nz < 0: coordinates.z -= 1; nz += chunk_size
	while nz >= chunk_size: coordinates.z += 1; nz -= chunk_size
	
	var chunk = registry.get(coordinates)
	if not chunk is PackedByteArray:
		return true
		
	return chunk[nx + ny * chunk_size + nz * chunk_size * chunk_size] == 0

static func get_hex_world_position(
	position: Vector3i, 
	scale: float, 
	height: float
) -> Vector3:
	return Vector3(
		scale * (1.5 * float(position.x)),
		float(position.y) * height,
		scale * (sqrt(3.0) * (float(position.z) + 0.5 * float(position.x)))
	)

static func _get_hex_points(
	center: Vector3, 
	scale: float, 
	y_offset: float
) -> Array[Vector3]:
	var points: Array[Vector3] = []
	
	for i in range(6):
		var angle: float = deg_to_rad(60.0 * float(i))
		points.append(center + Vector3(cos(angle) * scale, y_offset, sin(angle) * scale))
	
	return points

static func add_textured_triangle(
	p1: Vector3, 
	p2: Vector3, 
	p3: Vector3,
	uv1: Vector2, 
	uv2: Vector2, 
	uv3: Vector2,
	normal: Vector3, 
	texture_index: int,
	vertices: PackedVector3Array, 
	normals: PackedVector3Array, 
	tangents: PackedFloat32Array, 
	uvs: PackedVector2Array
) -> void:
	vertices.append_array([p1, p2, p3])
	normals.append_array([normal, normal, normal])
	
	# Store texture_index in TANGENT.x
	var t: float = float(texture_index)
	for i: int in range(3):
		tangents.append_array([t, 0.0, 0.0, 1.0])
		
	# Append RAW UVs (0.0 to 1.0). 
	# The shader handles the rest via the index.
	uvs.append_array([uv1, uv2, uv3])

static func _add_side(
	p1: Vector3, 
	p2: Vector3, 
	p3: Vector3, 
	p4: Vector3, 
	normal: Vector3, 
	_color: Color, 
	vertices: PackedVector3Array, 
	normals: PackedVector3Array, 
	colors: PackedColorArray
) -> void:
	var face_color: Color = Color(0, 0, 1, 1) 
	add_triangle(p1, p2, p3, normal, face_color, vertices, normals, colors)
	add_triangle(p1, p3, p4, normal, face_color, vertices, normals, colors)

static func _add_textured_side(
	p1: Vector3, 
	p2: Vector3, 
	p3: Vector3, 
	p4: Vector3, 
	normal: Vector3, 
	texture_index: int,
	vertices: PackedVector3Array, 
	normals: PackedVector3Array, 
	tangents: PackedFloat32Array, 
	uvs: PackedVector2Array
) -> void:
	var map = VoxelEngineConstants.Hexagon.UV_MAP["SIDE"]
	add_textured_triangle(p1, p2, p3, map[0], map[1], map[2], normal, texture_index, vertices, normals, tangents, uvs)
	add_textured_triangle(p1, p3, p4, map[0], map[2], map[3], normal, texture_index, vertices, normals, tangents, uvs)

static func _add_cap(
	points: Array[Vector3], 
	is_top: bool, 
	_color:Color, 
	vertices: PackedVector3Array, 
	normals: PackedVector3Array, 
	colors: PackedColorArray
) -> void:
	var center: Vector3 = Vector3.ZERO
	for point in points: center += point
	center /= 6.0
	
	var face_color: Color = Color(1, 0, 0, 1) if is_top else Color(0, 1, 0, 1)
	var normal: Vector3 = Vector3.UP if is_top else Vector3.DOWN
	
	for i in range(6):
		var next: int = (i + 1) % 6
		if is_top:
			add_triangle(center, points[i], points[next], normal, face_color, vertices, normals, colors)
		else:
			add_triangle(center, points[next], points[i], normal, face_color, vertices, normals, colors)

static func _add_textured_cap(
	points: Array[Vector3], 
	is_top: bool, 
	texture_index: int,
	vertices: PackedVector3Array, 
	normals: PackedVector3Array, 
	tangents: PackedFloat32Array,
	uvs: PackedVector2Array
) -> void:
	var center: Vector3 = Vector3.ZERO
	for p: Vector3 in points: center += p
	center /= 6.0
	
	var normal: Vector3 = Vector3.UP if is_top else Vector3.DOWN
	var map = VoxelEngineConstants.Hexagon.UV_MAP["TOP" if is_top else "BOTTOM"]
	
	# Calculate UV Center
	# This must match the (cx, cy) used in the Python script / Constants
	var cx = VoxelEngineConstants.Hexagon.PIXEL_CENTER_X / 512.0
	var cy = (VoxelEngineConstants.Hexagon.PIXEL_CENTER_Y + (-32.0 - VoxelEngineConstants.Hexagon.APOTHEM if is_top else 32.0 + VoxelEngineConstants.Hexagon.APOTHEM)) / 512.0
	var uv_center: Vector2 = Vector2(cx, cy) 

	for i: int in range(6):
		var next: int = (i + 1) % 6
		
		var uv1: Vector2 = map[i]
		var uv2: Vector2 = map[next]
		
		# Winding order: center -> points[i] -> points[next]
		# UV order: uv_center -> uv1 -> uv2
		if is_top:
			add_textured_triangle(center, points[i], points[next], uv_center, uv1, uv2, normal, texture_index, vertices, normals, tangents, uvs)
		else:
			# Bottom face: reverse order to maintain correct normal/winding
			add_textured_triangle(center, points[next], points[i], uv_center, uv2, uv1, normal, texture_index, vertices, normals, tangents, uvs)
