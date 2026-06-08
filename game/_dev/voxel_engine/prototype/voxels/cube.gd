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

static func calculate_geometry(data: PackedByteArray, coords: Vector3i, registry: Dictionary, size: int, colors: Array[Color]) -> Dictionary:
	var vertices_out: PackedVector3Array = PackedVector3Array()
	var normals_out: PackedVector3Array = PackedVector3Array()
	var colors_out: PackedColorArray = PackedColorArray()
	
	for x: int in range(size):
		for y: int in range(size):
			for z: int in range(size):
				var index: int = x + size * (y + size * z)
				if data[index] == 0:
					continue
				
				for f: int in range(6):
					var face_key: Face = Face.values()[f]
					var normal: Vector3 = face_normals[face_key]
					var nx: int = x + int(normal.x)
					var ny: int = y + int(normal.y)
					var nz: int = z + int(normal.z)
					
					var will_show: bool = false
					if nx >= 0 and nx < size and ny >= 0 and ny < size and nz >= 0 and nz < size:
						will_show = data[nx + size * (ny + size * nz)] == 0
					else:
						var neighbor_data: Variant = registry.get(coords + Vector3i(normal))
						if neighbor_data:
							var n_idx: int = ((nx % size + size) % size) + size * (((ny % size + size) % size) + size * ((nz % size + size) % size))
							will_show = neighbor_data[n_idx] == 0
						else:
							will_show = true
					
					if will_show:
						for triangle: Array in face_indices[face_key]:
							for vertex_index: int in triangle:
								vertices_out.append(vertices[vertex_index] + Vector3(float(x), float(y), float(z)))
								normals_out.append(normal)
								colors_out.append(colors[data[index] - 1])
								
	return {"verts": vertices_out, "norms": normals_out, "cols": colors_out}
