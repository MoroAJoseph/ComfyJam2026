class_name NewVoxelEngineGenerator 
extends RefCounted

## Generates raw voxel data for a single chunk.
## Purely functional to allow for easy threading.
static func generate_raw_voxels(
	origin: Vector3, 
	chunk_size: int,
	noise: FastNoiseLite, 
	max_height: int, 
	sea_level: int,
	logic_class: Object
) -> PackedByteArray:
	var voxels := PackedByteArray()
	voxels.resize(chunk_size * chunk_size * chunk_size)
	voxels.fill(0)

	for x in range(chunk_size):
		for z in range(chunk_size):
			for y in range(chunk_size):
				# Retrieve world position via the polymorphic logic class
				var world_pos = origin + logic_class.voxel_to_world(
					Vector3i(x, y, z), Vector3.ZERO
				)

				# Density calculation
				var density := noise.get_noise_3d(world_pos.x, world_pos.y, world_pos.z)
				var height_gradient = world_pos.y / float(max_height)
				var final_density = density - height_gradient

				# Voxel Type Logic
				if final_density > 0.0 and world_pos.y >= sea_level:
					var voxel_type := 1 # Default rock
					
					if world_pos.y < sea_level + 2:
						voxel_type = 3 # Sand/Bottom layer
					elif world_pos.y < sea_level + 5:
						voxel_type = 2 # Grass/Top layer

					# Flattened 3D coordinate to 1D index
					var idx = x + (y * chunk_size) + (z * chunk_size * chunk_size)
					voxels[idx] = voxel_type

	return voxels
