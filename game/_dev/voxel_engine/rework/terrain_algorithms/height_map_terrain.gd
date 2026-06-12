class_name HeightMapTerrain extends TerrainAlgorithm

func _init() -> void:
	name = "HeightMapTerrain"
	
func create_name() -> String:
	return name + "_" + noise.name + "_" + str(max_height)

func generate_data(position: Vector3, biome_noise: Noise, chunk_data, geometry: RefCounted = null) -> void:
	var chunk_size = chunk_data.GetSize()
	
	for x in range(chunk_size):
		for z in range(chunk_size):
			# FIX: Get the true world position of this specific hex cell
			var world_pos_xz = _get_world_xz(position, x, z, geometry)
			
			# Sample your height noise using the real physical layout positions
			var height = noise.get_height(world_pos_xz, max_height)
			
			if height < position.y: continue
			
			var local_height = height - position.y
			for y in range(min(local_height, chunk_size)):
				
				# FIX: Use world_pos_xz here too so biomes line up with the shapes!
				var biome_n = ((biome_noise.get_noise_2d(world_pos_xz.x, world_pos_xz.y) + 0.5 * biome_noise.get_noise_2d(2*world_pos_xz.x, 2*world_pos_xz.y)+0.25*biome_noise.get_noise_2d(4*world_pos_xz.x, 4*world_pos_xz.y)) / 1.75 + 1.0) / 2.0
				var biome = Voxel.SAND
				if biome_n > 0.55: biome = Voxel.GRASS
				if (y+position.y) / max_height >= 0.22: 
					biome = Voxel.MOUNTAIN
					if biome_n > 0.5 && (y+position.y) / max_height > 0.4 : biome = Voxel.SNOW
					
				chunk_data.AddVoxel(x, y, z, biome)

func _get_world_xz(chunk_pos: Vector3, x: int, z: int, geometry: RefCounted) -> Vector2:
	if geometry and geometry.has_method("get_world_position"):
		var pos = geometry.get_world_position(Vector3i(x, 0, z))
		return Vector2(chunk_pos.x + pos.x, chunk_pos.z + pos.z)
	return Vector2(chunk_pos.x + x, chunk_pos.z + z)
