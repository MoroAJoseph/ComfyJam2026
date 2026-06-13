class_name VoxelBlueprintIslandGenerator
extends RefCounted

static func generate_island(
	island_size: Vector2i,
	rng: RandomNumberGenerator,
	cove_weights: Array[float],
	flat_gauge: float,
	max_height: int
) -> Array[float]:
	var map: Array[float] = []
	map.resize(island_size.x * island_size.y)
	map.fill(0.0)

	_add_sloped_backbone(
		map,
		island_size,
		rng.randf_range(0.3, 0.9),
		rng.randi()
	)

	for i in range(rng.randi_range(4, 8)):
		_add_gaussian_blob(
			map,
			island_size,
			Vector2(
				rng.randf() * island_size.x,
				rng.randf() * island_size.y
			),
			rng.randf_range(4.0, 10.0)
		)

	_apply_flattening(map, island_size, flat_gauge)
	_apply_edge_mask(map, island_size, rng.randi())

	_normalize_map(map)

	for i in range(map.size()):
		map[i] *= float(max_height)

	var rotation_offset := rng.randf() * TAU
	var radius = min(island_size.x, island_size.y) * 0.4

	for i in range(cove_weights.size()):
		var angle = (float(i) / max(1, cove_weights.size())) * TAU + rotation_offset
		var shelf_pos = Vector2(island_size) * 0.5 + Vector2(cos(angle), sin(angle)) * radius

		_add_cove(map, island_size, shelf_pos, cove_weights[i])

	_apply_edge_mask(map, island_size, rng.randi())
	_apply_noise_warp(map, island_size, rng.randi(), rng.randf_range(0.02, 0.08))

	_normalize_map(map)

	for i in range(map.size()):
		map[i] *= float(max_height)

	return map


static func generate_island_voxels(
	heightmap: Array[float],
	island_size: Vector3i,
	sea_height: float,
	rng: RandomNumberGenerator,
	cave_radius: float,
	cave_weights: Array[float],
	spawn_matrix: Dictionary,
	_spawn_rules: Array
) -> Dictionary:
	var data: Dictionary = {}
	var cave_seed := rng.randi()

	for x in range(island_size.x):
		for z in range(island_size.z):
			var h := int(clampf(heightmap[x + z * island_size.x], 0.0, float(island_size.y)))

			for y in range(h):
				var pos := Vector3i(x, y, z)

				if _is_inside_cave(pos, island_size, cave_weights, cave_radius, cave_seed):
					continue

				data[pos] = _get_pooled_block(pos, spawn_matrix, rng, island_size)

	return data


# --------------------
# BLOCK SELECTION
# --------------------

static func _get_pooled_block(
	pos: Vector3i,
	spawn_matrix: Dictionary,
	rng: RandomNumberGenerator,
	dims: Vector3i
) -> int:

	var y_norm = float(pos.y) / max(1.0, float(dims.y))

	var candidates := []
	var weights := []

	for block_type in spawn_matrix.keys():
		var rule = spawn_matrix[block_type]

		if pos.y < rule["min"] or pos.y > rule["max"]:
			continue

		var curve: Curve = rule["curve"]
		var w := curve.sample(clampf(y_norm, 0.0, 1.0))

		if w > 0.001:
			candidates.append(block_type)
			weights.append(w)

	if candidates.is_empty():
		return 0

	var total := 0.0
	for w in weights:
		total += w

	var roll := rng.randf() * total
	var acc := 0.0

	for i in range(candidates.size()):
		acc += weights[i]
		if roll <= acc:
			return int(candidates[i])

	return int(candidates.back())

static func _normalize_map(map: Array[float]):
	var min_h = map.min()
	var max_h = map.max()
	var range_h = max_h - min_h
	if range_h <= 0.0:
		return

	for i in range(map.size()):
		map[i] = (map[i] - min_h) / range_h


static func _apply_edge_mask(map: Array[float], dims: Vector2i, seed: int):
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = 0.025

	var center := Vector2(dims) * 0.5
	var base_radius = min(dims.x, dims.y) * 0.45

	for x in range(dims.x):
		for y in range(dims.y):
			var idx := x + y * dims.x

			var dir := Vector2(x, y) - center
			var dist := dir.length()

			var angle := atan2(dir.y, dir.x)

			var coast_noise := noise.get_noise_2d(
				cos(angle) * 50.0,
				sin(angle) * 50.0
			)

			var radius = base_radius * (1.0 + coast_noise * 0.25)

			var t := clampf(dist / radius, 0.0, 1.0)
			var mask := 1.0 - pow(t, 6.0)

			map[idx] *= mask


static func _apply_flattening(map: Array[float], dims: Vector2i, intensity: float):
	if intensity <= 0.0:
		return

	var target := 4.0

	for i in range(map.size()):
		if map[i] > target:
			map[i] = lerpf(map[i], target, intensity)


static func _add_sloped_backbone(map: Array[float], dims: Vector2i, angle: float, seed: int):
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = 0.03

	var center := Vector2(dims) * 0.5
	var base_radius = min(dims.x, dims.y) * 0.42

	for x in range(dims.x):
		for y in range(dims.y):
			var idx := x + y * dims.x

			var dir := Vector2(x, y) - center
			var dist := dir.length()

			var normalized = dist / base_radius
			var falloff := clampf(1.0 - normalized, 0.0, 1.0)
			falloff = pow(falloff, 3.0)

			map[idx] += falloff * 10.0


static func _add_gaussian_blob(map: Array[float], dims: Vector2i, pos: Vector2, strength: float):
	for x in range(dims.x):
		for y in range(dims.y):
			var dx := x - pos.x
			var dy := y - pos.y

			var d2 := dx * dx + dy * dy
			var w := exp(-d2 / 50.0)

			map[x + y * dims.x] += w * strength


static func _apply_noise_warp(map: Array[float], dims: Vector2i, seed: int, freq: float):
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = freq

	for x in range(dims.x):
		for y in range(dims.y):
			map[x + y * dims.x] += noise.get_noise_2d(x, y) * 0.75


static func _add_cove(map: Array[float], dims: Vector2i, pos: Vector2, weight: float):
	var radius := dims.x * 0.2 * clampf(weight, 0.1, 1.0)

	for x in range(dims.x):
		for y in range(dims.y):
			if Vector2(x, y).distance_to(pos) < radius:
				map[x + y * dims.x] = 0.5


static func _is_inside_cave(pos: Vector3i, dims: Vector3i, cave_weights: Array[float], base_radius: float, seed: int) -> bool:
	for i in range(cave_weights.size()):
		var angle = (float(i) / max(1, cave_weights.size())) * TAU
		var center := Vector3(dims.x * 0.5, 2.0, dims.z * 0.5)
		center += Vector3(cos(angle), 0, sin(angle)) * min(dims.x, dims.z) * 0.25

		var d := Vector3(pos).distance_to(center)
		var r := base_radius * clampf(cave_weights[i], 0.5, 1.5)

		if d < r and pos.y > 1 and pos.y < dims.y * 0.7:
			return true

	return false
