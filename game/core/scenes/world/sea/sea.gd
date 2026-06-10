class_name WorldSea
extends Node3D

@export var height: float = 8.0
@export var choppy: float
@export var speed: float
@export var frequency: float 
@export var water_level: float
@export var tile_size: float = 500.0
@export var tile_scene: PackedScene
@export var render_radius: int = 2

# TODO: Dynamically render ocean collision shape
# NOTE: Collision shape is just for ray casts and environment-awareness

var last_player_tile: Vector2i = Vector2i(999999, 999999)
var active_tiles: Dictionary[Vector2i, MeshInstance3D] = {}
var shared_material: ShaderMaterial

var ITER_GEOMETRY: int

var octave_m = [Vector2(1.6, 1.2), Vector2(-1.2, 1.6)]

# ===
# Built-In
# ===

func _ready():
	Session.world_provider.set_sea(self)
	
	var template = tile_scene.instantiate()
	shared_material = template.get_active_material(0).duplicate()
	template.queue_free()
	
	shared_material.set_shader_parameter("sea_height", height)
	shared_material.set_shader_parameter("sea_chopy", choppy)
	shared_material.set_shader_parameter("sea_speed", speed)
	shared_material.set_shader_parameter("sea_freq", frequency)
	shared_material.set_shader_parameter("water_level", water_level)

	ITER_GEOMETRY = shared_material.get_shader_parameter("ITER_GEOMETRY")

func _process(_delta: float):
	shared_material.set_shader_parameter("cpu_time", Session.world_context.cpu_time)
	var player_context: PlayerContext = Session.player_context
	
	var current_tile = Vector2i(
		floor(player_context.world_location.x / tile_size), 
		floor(player_context.world_location.z / tile_size)
	)
	if current_tile != last_player_tile:
		last_player_tile = current_tile
		_update_grid()

# ===
# Public
# ===

func get_height(world_pos: Vector3, time: float = -1.0) -> float:
	if time == -1.0: 
		time = Session.world_context.cpu_time
	
	var curent_frequency = shared_material.get_shader_parameter("sea_freq")
	var current_height = shared_material.get_shader_parameter("sea_height")
	var current_choppy = shared_material.get_shader_parameter("sea_choppy")
	var current_speed = shared_material.get_shader_parameter("sea_speed")
	var curent_water_level = shared_material.get_shader_parameter("water_level")
	var current_iteratons = int(shared_material.get_shader_parameter("ITER_GEOMETRY"))
	
	var uv = Vector2(world_pos.x * 0.75, world_pos.z)
	var base_height = 0.0
	var time_value = time * current_speed
	var time_vec2 = Vector2(time_value, time_value)
	
	for i in range(current_iteratons):
		var depth = _sea_octave((uv + time_vec2) * curent_frequency, current_choppy)
		depth += _sea_octave((uv - time_vec2) * curent_frequency, current_choppy)
		base_height += depth * current_height
		uv = Vector2(uv.dot(octave_m[0]), uv.dot(octave_m[1]))
		curent_frequency *= 1.9
		current_height *= 0.22
		current_choppy = lerp(current_choppy, 1.0, 0.2)
	
	return curent_water_level + base_height

# ===
# Private
# ===

func _sea_octave(uv: Vector2, current_choppy: float) -> float:
	uv += Vector2(_noise(uv), _noise(uv))
	var wv = Vector2(1.0, 1.0) - Vector2(abs(sin(uv.x)), abs(sin(uv.y)))
	var swv = Vector2(abs(cos(uv.x)), abs(cos(uv.y)))
	wv = lerp(wv, swv, wv)
	return pow(1.0 - pow(wv.x * wv.y, 0.65), current_choppy)

func _noise(pos: Vector2) -> float:
	var i = floor(pos)
	var f = pos - i
	var u = f * f * (Vector2(3.0, 3.0) - (Vector2(2.0, 2.0) * f))
	
	return -1.0 + 2.0 * lerp(
		lerp(
			_hash12(i + Vector2(0.0, 0.0)), 
			_hash12(i + Vector2(1.0, 0.0)), 
			u.x
		),
		lerp(
			_hash12(i + Vector2(0.0, 1.0)), 
			_hash12(i + Vector2(1.0, 1.0)), 
			u.x
		),
		u.y
	)

func _hash12(pos: Vector2) -> float:
	var q = Vector2i(pos) * Vector2i(1597334677, 3812015801)
	var n = (q.x ^ q.y) * 1597334677
	return float(n & 0xFFFFFFFF) * (1.0 / 4294967295.0)

func _update_grid():
	
	# Calculate required tiles
	var needed_tiles: Array[Vector2i] = []
	for x in range(-render_radius, render_radius + 1):
		for z in range(-render_radius, render_radius + 1):
			needed_tiles.append(last_player_tile + Vector2i(x, z))
			
	# Cleanup old tiles
	for coord in active_tiles.keys():
		if coord not in needed_tiles:
			active_tiles[coord].queue_free()
			active_tiles.erase(coord)
			
	# Spawn new tiles
	for coord in needed_tiles:
		if not active_tiles.has(coord):
			_spawn_tile(coord)

func _spawn_tile(coord: Vector2i):
	var tile_instance = tile_scene.instantiate()
	
	# Calculate distance for LOD logic
	var dist = max(
		abs(coord.x - last_player_tile.x), 
		abs(coord.y - last_player_tile.y)
	)
	
	# Determine LOD level (0: Near, 1: Mid, 2: Far)
	var lod_level = 2
	var subs = 64
	if dist <= 1: 
		lod_level = 0
		subs = 256
	elif dist <= 3: 
		lod_level = 1
		subs = 128
		
	tile_instance.name = "OceanTile_LOD%d_%d_%d" % [lod_level, coord.x, coord.y]
	
	add_child(tile_instance)
	
	# Mesh setup
	if tile_instance is MeshInstance3D and tile_instance.mesh is PlaneMesh:
		tile_instance.mesh = tile_instance.mesh.duplicate() # Ensure unique mesh for LOD
		tile_instance.mesh.size = Vector2(tile_size, tile_size)
		tile_instance.mesh.subdivide_depth = subs - 1
		tile_instance.mesh.subdivide_width = subs - 1
	
	tile_instance.global_position = Vector3(
		coord.x * tile_size, 
		0, 
		coord.y * tile_size
	)
	tile_instance.set_surface_override_material(0, shared_material)
	
	active_tiles[coord] = tile_instance
