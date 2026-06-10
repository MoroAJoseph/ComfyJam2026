class_name VoxelEngineCube
extends VoxelEngineVoxel


## Generates geometry for a single voxel, checking neighbors to skip internal faces.
static func get_single_voxel_geometry(
	voxel: Vector3i,
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	size: int,
	colors: PackedColorArray
) -> Dictionary:
	var vertices_array: PackedVector3Array = PackedVector3Array()
	var normals_array: PackedVector3Array = PackedVector3Array()
	var colors_array: PackedColorArray = PackedColorArray()
	var uvs_array: PackedVector2Array = PackedVector2Array()

	# Use the first color in the array for single voxel highlighting
	var voxel_color = colors[0] if not colors.is_empty() else Color.WHITE

	for face_index in range(6):
		var face_key: VoxelEngineEnums.CubeFace = VoxelEngineEnums.CubeFace.values()[face_index]
		var normal: Vector3 = VoxelEngineConstants.Cube.FACE_NORMALS[face_key]
		var neighbor: Vector3i = voxel + Vector3i(normal)

		if _is_air_cube(
			neighbor.x, 
			neighbor.y, 
			neighbor.z, 
			data, 
			coordinates,
			registry, 
			size
		):
			for triangle in VoxelEngineConstants.Cube.FACE_INDICES[face_key]:
				var point1: Vector3 = VoxelEngineConstants.Cube.VERTICES[triangle[0]]
				var point2: Vector3 = VoxelEngineConstants.Cube.VERTICES[triangle[1]]
				var point3: Vector3 = VoxelEngineConstants.Cube.VERTICES[triangle[2]]
				
				add_triangle(
					point1, 
					point2, 
					point3, normal, 
					voxel_color, 
					vertices_array, 
					normals_array, 
					colors_array
				)
	
	return {
		"vertices": vertices_array, 
		"normals": normals_array, 
		"colors": colors_array, 
		"uvs": uvs_array
	}

## Checks if a coordinate in 3D space represents an air (empty) voxel.
static func _is_air_cube(
	x: int, y: int, z: int,
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	size: int
) -> bool:
	if x >= 0 and x < size and y >= 0 and y < size and z >= 0 and z < size:
		return data[get_index(x, y, z, size)] == 0
	
	var neighbor_coordinates: Vector3i = coordinates + Vector3i(
		1 if x >= size else (-1 if x < 0 else 0),
		1 if y >= size else (-1 if y < 0 else 0),
		1 if z >= size else (-1 if z < 0 else 0)
	)
	
	var neighbor_data = registry.get(neighbor_coordinates)
	if neighbor_data is PackedByteArray:
		return neighbor_data[get_index((x % size + size) % size, (y % size + size) % size, (z % size + size) % size, size)] == 0
	
	return true

## Calculates noise sampling coordinates based on world origin.
static func get_noise_coordinates(
	x: int, 
	z: int, 
	world_origin: Vector3
) -> Vector2:
	return Vector2(
		world_origin.x + float(x), 
		world_origin.z + float(z)
	)

## Converts a world-space position into a local Vector3i voxel index.
static func world_to_local(
	world_position: Vector3, 
	chunk_origin: Vector3
) -> Vector3i:
	var relative_position: Vector3 = (world_position - chunk_origin) + Vector3(0.5, 0.5, 0.5)
	return Vector3i(
		floor(relative_position.x), 
		floor(relative_position.y), 
		floor(relative_position.z)
	)

## Maps a world-space position to its corresponding chunk coordinate.
static func world_to_chunk(
	world_position: Vector3, 
	chunk_size: int
) -> Vector3i:
	return Vector3i(
		floori(world_position.x / float(chunk_size)),
		floori(world_position.y / float(chunk_size)),
		floori(world_position.z / float(chunk_size))
	)

## Converts chunk coordinates to world-space position.
static func chunk_to_world(coordinate: Vector3i, size: int) -> Vector3:
	return Vector3(coordinate) * float(size)

## Converts a specific voxel coordinate to world-space position.
static func voxel_to_world(voxel: Vector3i, chunk_origin: Vector3) -> Vector3:
	return Vector3(voxel) + chunk_origin

## Maps a specific voxel coordinate to its parent chunk coordinate.
static func voxel_to_chunk(voxel: Vector3i, chunk_size: int) -> Vector3i:
	return voxel / chunk_size * chunk_size

## Builds the mesh geometry for an entire chunk of voxels.
static func calculate_geometry(
	data: PackedByteArray,
	_coordinates: Vector3i,
	_registry: Dictionary,
	size: int,
	colors: PackedColorArray
) -> Dictionary:
	var vertices_array := PackedVector3Array()
	var normals_array := PackedVector3Array()
	var uvs_array := PackedVector2Array()

	for x in range(size):
		for y in range(size):
			for z in range(size):
				if data[get_index(x, y, z, size)] == 0:
					continue
				
				for face_index in range(6):
					var face_key: VoxelEngineEnums.CubeFace = VoxelEngineEnums.CubeFace.values()[face_index]
					var normal: Vector3 = VoxelEngineConstants.Cube.FACE_NORMALS[face_key]
					var neighbor_x: int = x + int(normal.x)
					var neighbor_y: int = y + int(normal.y)
					var neighbor_z: int = z + int(normal.z)
					
					var show_face: bool = (
						neighbor_x < 0 or 
						neighbor_x >= size or 
						neighbor_y < 0 or 
						neighbor_y >= size or 
						neighbor_z < 0 or 
						neighbor_z >= size
					)
					if not show_face:
						show_face = (data[get_index(neighbor_x, neighbor_y, neighbor_z, size)] == 0)
					
					if show_face:
						for triangle in VoxelEngineConstants.Cube.FACE_INDICES[face_key]:
							var offset: Vector3 = Vector3(
								float(x), 
								float(y), 
								float(z)
							)
							var point1: Vector3 = VoxelEngineConstants.Cube.VERTICES[triangle[0]] + offset
							var point2: Vector3 = VoxelEngineConstants.Cube.VERTICES[triangle[1]] + offset
							var point3: Vector3 = VoxelEngineConstants.Cube.VERTICES[triangle[2]] + offset
							add_triangle(
								point1, 
								point2, 
								point3, 
								normal, 
								colors[data[get_index(x, y, z, size)] - 1], 
								vertices_array, 
								normals_array, 
								colors
							)
	
	return {
		"vertices": vertices_array, 
		"normals": normals_array, 
		"colors": colors, 
		"uvs": uvs_array
	}
