class_name BinaryTerrain 
extends TerrainAlgorithm

func _ready() -> void:
	name = "BinaryTerrain"
	
func create_name() -> String:
	return name + "_" + noise.name + "_" + str(max_height)

func generate_data(position: Vector3, biome_noise: Noise, chunk_data, geometry: RefCounted = null) -> void:
	var chunk_size = chunk_data.GetSize() # Explicitly matching your C# case-sensitive methods
	
	for x in range(chunk_size):
		for z in range(chunk_size):
			# DECOUPLING FIX: Get world position based on grid layout shape
			var world_pos_xz = _get_world_xz(position, x, z, geometry)
			var height = noise.get_height(world_pos_xz, max_height)
			
			if height < position.y: continue
			
			var local_height = height - position.y
			for y in range(min(local_height, chunk_size)):
				# BinaryTerrain logic defaults to GRASS
				chunk_data.AddVoxel(x, y, z, Voxel.GRASS)

func _get_world_xz(chunk_pos: Vector3, x: int, z: int, geometry: RefCounted) -> Vector2:
	# If a hex layout is used, calculate staggered positioning
	if geometry and geometry.has_method("get_world_position"):
		var pos = geometry.get_world_position(Vector3i(x, 0, z))
		return Vector2(chunk_pos.x + pos.x, chunk_pos.z + pos.z)
	# Fallback to standard orthogonal cube layout
	return Vector2(chunk_pos.x + x, chunk_pos.z + z)
