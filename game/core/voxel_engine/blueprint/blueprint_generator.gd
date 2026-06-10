class_name VoxelEngineBlueprintGenerator
extends RefCounted

static func generate_dock_island(dims: Vector2i, seed: int, dock_weights: Array[float], flat_gauge: float, max_h: int) -> Array[float]:
	var map: Array[float] = []
	map.resize(dims.x * dims.y)
	map.fill(0.0)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	# Base Structure
	_add_sloped_backbone(map, dims, rng.randf_range(0.3, 0.9))
	
	# Add organic variation
	for i in range(rng.randi_range(1, 3)):
		_add_gaussian_blob(map, dims, Vector2(rng.randf()*dims.x, rng.randf()*dims.y), rng.randf_range(2.0, 5.0))
	
	# Apply flattening before normalization
	_apply_flattening(map, dims, flat_gauge)
	
	# Prevent island from generating out of bounds
	_apply_edge_mask(map, dims)
	
	# Normalize to 0.0 - 1.0 range, then scale to max_h
	_normalize_map(map)
	for i in range(map.size()):
		map[i] *= float(max_h)
	
	# Docks (Placed after normalization)
	var rotation_offset = rng.randf() * PI * 2.0
	var radius = min(dims.x, dims.y) * 0.4
	for i in range(dock_weights.size()):
		var angle = (float(i) / max(1, dock_weights.size())) * PI * 2.0 + rotation_offset
		var shelf_pos = Vector2(dims) * 0.5 + Vector2(cos(angle), sin(angle)) * radius
		_add_dock_shelf(map, dims, shelf_pos, dock_weights[i])
	
	# 2nd edge mask for docks
	_apply_edge_mask(map, dims)
	
	# Final Erosion
	_apply_noise_warp(map, dims, seed, rng.randf_range(0.02, 0.08))
	
	return map

static func _get_block_type_from_rules(pos: Vector3i, rules: Array) -> int:
	var valid_rules = []
	for rule in rules:
		if pos.y >= rule.min_height and pos.y <= rule.max_height:
			valid_rules.append(rule)
			
	if valid_rules.is_empty():
		return 1

	var total_weight = 0.0
	for rule in valid_rules: total_weight += rule.density
	
	var threshold = randf() * total_weight
	var cumulative = 0.0
	for rule in valid_rules:
		cumulative += rule.density
		if threshold <= cumulative:
			return int(rule.block_type)
			
	return int(valid_rules[0].block_type)

static func generate_dock_voxels(heightmap: Array[float], dims: Vector3i, sea_h: float, seed: int, cave_radius: float, cave_weights: Array[float], spawn_rules: Array) -> Dictionary[Vector3i, int]:
	var data: Dictionary[Vector3i, int] = {}
	for x in dims.x:
		for z in dims.z:
			var h = int(clampf(heightmap[x + z * dims.x], 0.0, float(dims.y)))
			for y in range(h):
				if float(y) >= sea_h:
					var pos = Vector3i(x, y, z)
					# Check if this position is inside a cave volume
					var is_cave = is_inside_multi_cave(pos, dims, cave_weights, cave_radius, seed)
					
					# Logic: If it's a cave, we do NOT add it to 'data' (we carve it)
					# We removed 'is_near_edge' to allow caves to break through to the outside
					if is_cave:
						continue 
					else:
						data[pos] = _get_block_type_from_rules(pos, spawn_rules)
	return data

static func generate_terrain(dims: Vector3i, seed: int, max_h: int, sea_h: float) -> Dictionary[Vector3i, int]:
	var heightmap = generate_island_heightmap(Vector2i(dims.x, dims.z), seed, max_h)
	
	_apply_edge_mask(heightmap, Vector2i(dims.x, dims.z))
	
	var data: Dictionary[Vector3i, int] = {}
	for x in dims.x:
		for z in dims.z:
			var h = int(clampf(heightmap[x + z * dims.x], 0.0, float(max_h)))
			for y in range(h):
				if float(y) >= sea_h:
					data[Vector3i(x, y, z)] = 1
	return data

static func generate_island_heightmap(dims: Vector2i, seed: int, max_h: int) -> Array[float]:
	var map: Array[float] = []
	map.resize(dims.x * dims.y)
	map.fill(0.0)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	# Base Backbone
	_add_sloped_backbone(map, dims, rng.randf_range(0.3, 0.9))
	
	# Add organic noise/blobs
	for i in range(rng.randi_range(2, 4)):
		_add_gaussian_blob(map, dims, Vector2(rng.randf()*dims.x, rng.randf()*dims.y), rng.randf_range(2.0, 6.0))
	
	# Normalize & Scale
	_normalize_map(map)
	for i in range(map.size()):
		map[i] *= float(max_h)
		
	# Final Texture
	_apply_noise_warp(map, dims, seed, 0.05)
	
	return map

static func _normalize_map(map: Array[float]):
	var min_h = map.min()
	var max_h = map.max()
	var range_h = max_h - min_h
	if range_h <= 0.0: return
	for i in range(map.size()):
		map[i] = (map[i] - min_h) / range_h

static func _apply_edge_mask(map: Array[float], dims: Vector2i):
	var center = Vector2(dims) * 0.5
	var max_dist = min(dims.x, dims.y) * 0.45
	for x in dims.x:
		for y in dims.y:
			var d = Vector2(x, y).distance_to(center)
			if d > max_dist:
				# Smoothly fade to zero as we approach the edge
				var fade = clampf(1.0 - ((d - max_dist) / (min(dims.x, dims.y) * 0.05)), 0.0, 1.0)
				map[x + y * dims.x] *= fade

static func _apply_flattening(map: Array[float], dims: Vector2i, intensity: float):
	if intensity <= 0.0: return
	var target_height = 4.0 
	for i in range(map.size()):
		if map[i] > target_height:
			map[i] = lerpf(map[i], target_height, intensity)

static func _add_sloped_backbone(map: Array[float], dims: Vector2i, angle: float):
	var center = Vector2(dims) * 0.5
	var max_dist = min(dims.x, dims.y) * 0.45
	for x in dims.x:
		for y in dims.y:
			var d = Vector2(x, y).distance_to(center)
			var falloff = clampf(1.0 - (d / max_dist), 0.0, 1.0)
			map[x + y * dims.x] = pow(falloff, angle) * 8.0

static func _add_dock_shelf(map: Array[float], dims: Vector2i, pos: Vector2, weight: float):
	var radius = (dims.x * 0.2) * clampf(weight, 0.1, 1.0)
	for x in dims.x:
		for y in dims.y:
			if Vector2(x, y).distance_to(pos) < radius:
				map[x + y * dims.x] = 0.5 # Force shelf height

static func _add_gaussian_blob(map: Array[float], dims: Vector2i, pos: Vector2, strength: float):
	var radius = dims.x * 0.25
	for x in dims.x:
		for y in dims.y:
			var d = Vector2(x, y).distance_to(pos)
			if d < radius:
				map[x + y * dims.x] += exp(-(pow(d, 2.0) / (2.0 * pow(radius * 0.5, 2.0)))) * strength

static func _apply_noise_warp(map: Array[float], dims: Vector2i, seed: int, freq: float):
	var noise = FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = freq
	for x in dims.x:
		for y in dims.y:
			map[x + y * dims.x] += noise.get_noise_2d(x * 10.0, y * 10.0) * 1.5

static func is_inside_multi_cave(pos: Vector3i, dims: Vector3i, cave_weights: Array[float], base_radius: float, seed: int) -> bool:
	for i in range(cave_weights.size()):
		var angle = (float(i) / max(1, cave_weights.size())) * PI * 2.0
		var radius_offset = min(dims.x, dims.y) * 0.25 
		var center = Vector3(dims.x * 0.5, 2.0, dims.z * 0.5) + Vector3(cos(angle), 0, sin(angle)) * radius_offset
		
		var d = Vector3(pos).distance_to(center)
		var radius = base_radius * clampf(cave_weights[i], 0.5, 1.5)
		
		# Check if inside cave volume AND ensure we aren't at the very edge 
		# (prevents floating caves, requires entrance)
		if d < radius and pos.y > 1 and pos.y < (dims.y * 0.7):
			return true
			
	return false
