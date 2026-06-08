class_name VoxelEngineCube extends VoxelEngineVoxel

enum Face { FRONT, BACK, LEFT, RIGHT, TOP, BOTTOM }

static var vertices: Array[Vector3] = [
	Vector3(-0.5, -0.5, 0.5), Vector3(0.5, -0.5, 0.5),
	Vector3(0.5, -0.5, -0.5), Vector3(-0.5, -0.5, -0.5),
	Vector3(-0.5, 0.5, 0.5), Vector3(0.5, 0.5, 0.5),
	Vector3(0.5, 0.5, -0.5), Vector3(-0.5, 0.5, -0.5)
]

static var face_indices: Dictionary = {
	Face.FRONT: [[0, 4, 5], [0, 5, 1]],
	Face.BACK: [[2, 7, 3], [2, 6, 7]],
	Face.LEFT: [[3, 7, 4], [3, 4, 0]],
	Face.RIGHT: [[1, 5, 6], [1, 6, 2]],
	Face.TOP: [[0, 1, 2], [0, 2, 3]],
	Face.BOTTOM: [[4, 7, 6], [4, 6, 5]]
}

static var face_normals: Dictionary = {
	Face.FRONT: Vector3(0, 0, 1), Face.BACK: Vector3(0, 0, -1),
	Face.LEFT: Vector3(-1, 0, 0), Face.RIGHT: Vector3(1, 0, 0),
	Face.TOP: Vector3(0, -1, 0), Face.BOTTOM: Vector3(0, 1, 0)
}

static func get_single_voxel_geometry(voxel: Vector3i, data: PackedByteArray, coords: Vector3i, registry: Dictionary, size: int, color: Color) -> Dictionary:
	var v := PackedVector3Array(); var n := PackedVector3Array(); var c := PackedColorArray(); var u := PackedVector2Array()
	
	for f in range(6):
		var face_key: Face = Face.values()[f]
		var normal = face_normals[face_key]
		var neighbor := voxel + Vector3i(normal)
		
		if _is_air_cube(neighbor.x, neighbor.y, neighbor.z, data, coords, registry, size):
			for tri in face_indices[face_key]:
				var p1 = vertices[tri[0]] + Vector3(voxel)
				var p2 = vertices[tri[1]] + Vector3(voxel)
				var p3 = vertices[tri[2]] + Vector3(voxel)
				_add_tri(p1, p2, p3, normal, color, v, n, c, u)
	return {"verts": v, "norms": n, "cols": c, "uvs": u}

# Helper to keep the single-voxel logic clean
static func _is_air_cube(x: int, y: int, z: int, data: PackedByteArray, coords: Vector3i, registry: Dictionary, size: int) -> bool:
	if x >= 0 and x < size and y >= 0 and y < size and z >= 0 and z < size:
		return data[get_index(x, y, z, size)] == 0
	var n_coords := coords + Vector3i(1 if x>=size else (-1 if x<0 else 0), 1 if y>=size else (-1 if y<0 else 0), 1 if z>=size else (-1 if z<0 else 0))
	var n_data = registry.get(n_coords)
	if n_data is PackedByteArray:
		return n_data[get_index((x%size+size)%size, (y%size+size)%size, (z%size+size)%size, size)] == 0
	return true

static func get_noise_coords(_x: int, _z: int, world_origin: Vector3) -> Vector2:
	return Vector2(world_origin.x + float(_x), world_origin.z + float(_z))

static func world_to_local(world_pos: Vector3, chunk_origin: Vector3) -> Vector3i:
	# Adding 0.5 shifts the snapping range to center on the integer
	var rel := (world_pos - chunk_origin) + Vector3(0.5, 0.5, 0.5)
	return Vector3i(floor(rel.x), floor(rel.y), floor(rel.z))

static func world_to_chunk(world_pos: Vector3, chunk_size: int) -> Vector3i:
	return Vector3i(
		floori(world_pos.x / float(chunk_size)),
		floori(world_pos.y / float(chunk_size)),
		floori(world_pos.z / float(chunk_size))
	)

static func chunk_to_world(coord: Vector3i, size: int) -> Vector3:
	return Vector3(coord) * float(size)

static func voxel_to_world(voxel: Vector3i) -> Vector3:
	return Vector3(voxel)

static func voxel_to_chunk(voxel: Vector3i, chunk_size: int) -> Vector3i:
	return voxel / chunk_size * chunk_size

static func calculate_geometry(data: PackedByteArray, coords: Vector3i, registry: Dictionary, size: int, colors: Array[Color]) -> Dictionary:
	var v := PackedVector3Array(); var n := PackedVector3Array(); var c := PackedColorArray(); var u := PackedVector2Array()
	
	for x in range(size):
		for y in range(size):
			for z in range(size):
				if data[get_index(x, y, z, size)] == 0: continue
				
				for f in range(6):
					var face_key: Face = Face.values()[f]
					var normal = face_normals[face_key]
					var nx := x + int(normal.x); var ny := y + int(normal.y); var nz := z + int(normal.z)
					
					var show := (nx < 0 or nx >= size or ny < 0 or ny >= size or nz < 0 or nz >= size)
					if not show: show = (data[get_index(nx, ny, nz, size)] == 0)
					
					if show:
						for tri in face_indices[face_key]:
							var p1 = vertices[tri[0]] + Vector3(float(x), float(y), float(z))
							var p2 = vertices[tri[1]] + Vector3(float(x), float(y), float(z))
							var p3 = vertices[tri[2]] + Vector3(float(x), float(y), float(z))
							_add_tri(p1, p2, p3, normal, colors[data[get_index(x,y,z,size)]-1], v, n, c, u)
	return {"verts": v, "norms": n, "cols": c, "uvs": u}
