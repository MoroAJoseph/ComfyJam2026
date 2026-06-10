class_name TestVoxelEngineGenerator extends RefCounted

static func generate_chunk_data(
	origin: Vector3, 
	noise: FastNoiseLite, 
	chunk_size: int, 
	_max_height: int, 
	_colors: Array[Color], 
	_logic_class: Object
) -> PackedByteArray:
	var voxels := PackedByteArray()
	voxels.resize(chunk_size**3)
	voxels.fill(0)
	
	noise.seed = noise.seed # Ensure consistent seed
	noise.frequency = 0.015
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			for z in range(chunk_size):
				var world_pos = Vector3(x + origin.x, y + origin.y, z + origin.z)
				
				# 1. Base Density: Sample 3D noise
				var density = noise.get_noise_3d(world_pos.x, world_pos.y, world_pos.z)
				
				# 2. Vertical Falloff: Force density to decrease as we go higher
				# This ensures the world is solid at the bottom and air at the top
				var vertical_offset = (world_pos.y / 20.0) 
				
				# 3. Threshold Check
				# If density is high and we are below the "surface" falloff
				if density - vertical_offset > 0.0:
					var index = x + (y * chunk_size) + (z * chunk_size**2)
					voxels[index] = 1 
	return voxels
