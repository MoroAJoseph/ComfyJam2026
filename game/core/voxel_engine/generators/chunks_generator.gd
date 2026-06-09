class_name VoxelEngineChunksGenerator extends RefCounted

static func generate_raw_voxels(
	origin: Vector3, 
	noise: FastNoiseLite, 
	chunk_size: int, 
	height: int, 
	colors: Array[Color], 
	logic_class: Object
) -> PackedByteArray:
	var voxels := PackedByteArray()
	voxels.resize(chunk_size**3)
	voxels.fill(0)
	
	for x in range(chunk_size):
		for z in range(chunk_size):
			var sample: Vector2 = logic_class.get_noise_coords(x, z, origin)
			# Use Cellular noise here for better island shapes
			var value: float = (noise.get_noise_2d(sample.x, sample.y) + 1.0) / 2.0
			var sampled_height: = int(value * height)
			
			for y in range(
				min(
					int(max(0.0, sampled_height - origin.y)), 
					chunk_size
				)
			):
				voxels[x + (y * chunk_size) + (z * chunk_size**2)] = (y % colors.size()) + 1
	return voxels
