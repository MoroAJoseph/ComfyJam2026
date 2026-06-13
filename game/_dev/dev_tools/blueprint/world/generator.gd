class_name VoxelBlueprintWorldGenerator
extends RefCounted

static func generate_world(data: VoxelBlueprintWorldData, rng: RandomNumberGenerator) -> Dictionary:
	var zones := data.world_zone_data.duplicate()
	zones.sort_custom(func(a, b): return a.radius < b.radius)

	var blueprints: Array = []
	var dock_blueprints: Array = []
	var reserved: Array[Rect2i] = []

	for i in range(zones.size()):
		var zone = zones[i]
		var min_r = (zones[i - 1].radius if i > 0 else 0.0)
		var max_r = zone.radius

		# 1. DOCKS FIRST (must always generate)
		var dock_result := generate_zone_docks(zone, min_r, max_r, rng, reserved)

		for d in dock_result:
			blueprints.append(d)
			dock_blueprints.append(d)

		# 2. NORMAL ISLANDS
		var islands := generate_world_zone(zone, min_r, max_r, rng, reserved)

		for isl in islands:
			blueprints.append(isl)

	return {
		"blueprints": blueprints,
		"dock_blueprints": dock_blueprints
	}


static func generate_zone_docks(
	zone: WorldZoneData,
	min_r: float,
	max_r: float,
	rng: RandomNumberGenerator,
	reserved: Array[Rect2i]
) -> Array:

	var docks: Array = []

	for i in range(zone.dock_count):

		var r := rng.randf_range(min_r, max_r)
		var angle := rng.randf() * TAU

		var qf := cos(angle) * r
		var rf := sin(angle) * r

		var xf := qf
		var zf := rf
		var yf := -xf - zf

		var rx = round(xf)
		var ry = round(yf)
		var rz = round(zf)

		var dx = abs(rx - xf)
		var dy = abs(ry - yf)
		var dz = abs(rz - zf)

		if dx > dy and dx > dz:
			rx = -ry - rz
		elif dy > dz:
			ry = -rx - rz
		else:
			rz = -rx - ry

		var q := int(rx)
		var r_coord := int(rz)

		# MAX SIZE DOCKS
		var sx := clampi(zone.max_island_size.x, 4, 64)
		var sz := clampi(zone.max_island_size.z, 4, 64)

		var anchor := Vector2i(q - sx / 2, r_coord - sz / 2)

		var rect := Rect2i(anchor.x, anchor.y, sx, sz)
		reserved.append(rect)

		var dims := Vector3i(
			sx,
			zone.max_island_size.y,
			sz
		)

		var dock := generate_world_zone_island(
			zone,
			anchor,
			rng,
			dims,
			_dock_spawn_matrix(zone)
		)

		dock["is_dock"] = true

		docks.append(dock)

	return docks

static func generate_world_zone(
	zone: WorldZoneData,
	min_r: float,
	max_r: float,
	rng: RandomNumberGenerator,
	reserved: Array[Rect2i]
) -> Array:

	var islands: Array = []

	var area := PI * (max_r * max_r - min_r * min_r)
	var target := int(max(1.0, (area / 2000.0) * zone.island_density * 10.0))

	var buffer := clampi(int(zone.max_island_spacing), 1, 10)
	var failed := 0

	var spawn_matrix := _build_zone_spawn_matrix(zone)

	for i in range(5000):
		if islands.size() >= target:
			break

		# =========================
		# HEX-CONSISTENT RADIAL SAMPLING
		# =========================
		var r := rng.randf_range(min_r, max_r)
		var angle := rng.randf() * TAU

		# polar → axial float
		var qf := cos(angle) * r
		var rf := sin(angle) * r

		# axial float → cube
		var xf := qf
		var zf := rf
		var yf := -xf - zf

		var rx = round(xf)
		var ry = round(yf)
		var rz = round(zf)

		var dx = abs(rx - xf)
		var dy = abs(ry - yf)
		var dz = abs(rz - zf)

		if dx > dy and dx > dz:
			rx = -ry - rz
		elif dy > dz:
			ry = -rx - rz
		else:
			rz = -rx - ry

		# cube → axial
		var q := int(rx)
		var r_coord := int(rz)

		# Island size
		var sx := clampi(
			int(lerpf(zone.min_island_size.x, zone.max_island_size.x, zone.island_size_weight)),
			4,
			64
		)

		var sz := clampi(
			int(lerpf(zone.min_island_size.z, zone.max_island_size.z, zone.island_size_weight)),
			4,
			64
		)

		var dims := Vector3i(sx, zone.min_island_size.y, sz)

		# Anchor in hex-aligned grid space
		var anchor := Vector2i(
			q - sx / 2,
			r_coord - sz / 2
		)

		var rect := Rect2i(
			anchor.x - buffer,
			anchor.y - buffer,
			sx + buffer * 2,
			sz + buffer * 2
		)

		if _overlaps(rect, reserved):
			failed += 1
			if failed > 1000:
				break
			continue

		reserved.append(rect)

		islands.append(
			generate_world_zone_island(zone, anchor, rng, dims, spawn_matrix)
		)

	return islands

static func _dock_spawn_matrix(zone: WorldZoneData) -> Dictionary:
	var m := {}

	var flat_curve := Curve.new()
	flat_curve.add_point(Vector2(0, 1))
	flat_curve.add_point(Vector2(1, 1))

	m[Enums.BlockType.SAND] = {
		"curve": flat_curve,
		"min": 0,
		"max": 9999
	}

	m[Enums.BlockType.DIRT] = {
		"curve": flat_curve,
		"min": 0,
		"max": 9999
	}

	return m

static func generate_world_zone_island(zone: WorldZoneData, anchor: Vector2i, rng: RandomNumberGenerator, dims: Vector3i, spawn_matrix: Dictionary) -> Dictionary:
	var island_rng := RandomNumberGenerator.new()
	island_rng.seed = rng.randi()

	var cove_weights: Array[float] = []
	if island_rng.randf() <= zone.cove_density:
		for i in range(island_rng.randi_range(zone.min_cove_count, zone.max_cove_count)):
			cove_weights.append(island_rng.randf_range(zone.min_cove_weight, zone.max_cove_weight))

	var flatness := island_rng.randf_range(zone.min_island_flatness, zone.max_island_flatness)

	var heightmap := VoxelBlueprintIslandGenerator.generate_island(
		Vector2i(dims.x, dims.z),
		island_rng,
		cove_weights,
		flatness,
		dims.y
	)

	var voxels := VoxelBlueprintIslandGenerator.generate_island_voxels(
		heightmap,
		dims,
		1.0,
		island_rng,
		2.5,
		cove_weights,
		spawn_matrix,
		zone.block_spawn_rules
	)

	return {
		"anchor": anchor,
		"dims": dims,
		"voxels": voxels,
		"zone": zone
	}


static func zone_to_grid(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x), round(pos.y))


static func _overlaps(a: Rect2i, list: Array[Rect2i]) -> bool:
	var expanded := a.grow(1)
	for r in list:
		if expanded.intersects(r):
			return true
	return false


static func _random_pos(min_r: float, max_r: float, rng: RandomNumberGenerator) -> Vector2:
	var angle := rng.randf() * TAU
	var radius := sqrt(rng.randf_range(min_r * min_r, max_r * max_r))
	return Vector2(cos(angle), sin(angle)) * radius

static func _build_zone_spawn_matrix(zone: WorldZoneData) -> Dictionary:
	var m := {}

	for rule: VoxelBlueprintVoxelSpawnRule in zone.block_spawn_rules:
		m[rule.block_type] = {
			"curve": rule.height_curve,
			"min": rule.min_height,
			"max": rule.max_height
		}

	return m
