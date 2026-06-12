class_name Terrain3D extends TerrainAlgorithm

func _init() -> void:
	name = "Terrain3D"
	
func create_name() -> String:
	return name + "_" + noise.name + "_" + str(max_height)

func generate_data(position: Vector3, biome_noise: Noise, chunk_data, geometry: RefCounted = null) -> void:
	var chunk_size = chunk_data.GetSize()
	
	for x in range(chunk_size):
		for z in range(chunk_size):
			for y in range(chunk_size):
				# FIX: Calculate unified world position using the geometry resource
				var world_pos = _get_world_pos(position, x, y, z, geometry)
				var has_voxel = noise.has_voxel(world_pos)
				if !has_voxel: continue
			
				# Sample using real world coordinates
				var biome_n = ((biome_noise.get_noise_2d(world_pos.x, world_pos.z) + 0.5 * biome_noise.get_noise_2d(2*world_pos.x, 2*world_pos.z)+0.25*biome_noise.get_noise_2d(4*world_pos.x, 4*world_pos.z)) / 1.75 + 1.0) / 2.0
				var biome = Voxel.SAND
				if biome_n > 0.55: biome = Voxel.GRASS
				if (y+position.y) / max_height >= 0.22: 
					biome = Voxel.MOUNTAIN
					if biome_n > 0.5 && (y+position.y) / max_height > 0.4 : biome = Voxel.SNOW
					
				chunk_data.AddVoxel(x, y, z, biome)

func _get_world_pos(chunk_pos: Vector3, x: int, y: int, z: int, geometry: RefCounted) -> Vector3:
	if geometry and geometry.has_method("get_world_position"):
		return chunk_pos + geometry.get_world_position(Vector3i(x, y, z))
	return chunk_pos + Vector3(x, y, z)
