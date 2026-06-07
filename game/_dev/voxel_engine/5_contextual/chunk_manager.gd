class_name VoxelEngineContextualChunkManager
extends Node

@export var use_hexagons: bool = false
@export var use_collision: bool = false
@export var context_target: Node3D 
@export var dimensions: Vector3 = Vector3(64, 16, 64)
@export var chunk_size: int = 64
@export var noise_seed: int = 0
@export var generation_radius: int = 5
@export var render_radius: int = 5
@export var cube_chunk_scene: PackedScene
@export var hexagon_chunk_scene: PackedScene
@export var colors : Array[Color] = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW]

var noise = FastNoiseLite.new()
var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var active_chunks: Dictionary[Vector3i, Node3D] = {}
var current_player_chunk: Vector3i = Vector3i.ZERO
var data_initialized: bool = false

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = noise_seed
	generate_world_data()

func _process(_delta: float) -> void:
	if not data_initialized or not context_target: return
	var pos = context_target.global_position
	var new_c = Vector3i(round(pos.x / chunk_size), 0, round(pos.z / chunk_size))
	if new_c != current_player_chunk:
		current_player_chunk = new_c
		update_render_distance()

func generate_world_data() -> void:
	var r = generation_radius
	var y_max = ceil(dimensions.y / float(chunk_size))
	for x in range(-r, r+1):
		for z in range(-r, r+1):
			if Vector2(x, z).length() <= r:
				for y in range(0, int(y_max)):
					var c = Vector3i(x, y, z)
					chunks_data[c] = generate_raw_voxels(get_chunk_position(c))
	data_initialized = true
	print("- Total Chunks Cached: ", chunks_data.size())
	update_render_distance()

func generate_raw_voxels(origin: Vector3) -> PackedByteArray:
	var v = PackedByteArray(); v.resize(chunk_size**3); v.fill(0)
	for x in range(chunk_size):
		for z in range(chunk_size):
			var h = (noise.get_noise_2d(x + origin.x, z + origin.z) + 1.0) / 2.0 * dimensions.y
			for y in range(min(int(max(0, h - origin.y)), chunk_size)):
				v[x + (y * chunk_size) + (z * chunk_size**2)] = (y % colors.size()) + 1
	return v

func update_render_distance() -> void:
	var needed = []
	for x in range(-render_radius, render_radius+1):
		for z in range(-render_radius, render_radius+1):
			if Vector2(x, z).length() <= render_radius: needed.append(current_player_chunk + Vector3i(x, 0, z))
	for c in needed:
		if not active_chunks.has(c) and chunks_data.has(c): _spawn_chunk(c)
	for c in active_chunks.keys():
		if not c in needed:
			active_chunks[c].queue_free()
			active_chunks.erase(c)

func _spawn_chunk(c: Vector3i) -> void:
	var ch = (hexagon_chunk_scene if use_hexagons else cube_chunk_scene).instantiate()
	active_chunks[c] = ch
	ch.position = get_chunk_position(c)
	add_child(ch)
	WorkerThreadPool.add_task(func(): _process_mesh(c, chunks_data[c]))

func _process_mesh(c: Vector3i, data: PackedByteArray) -> void:
	var geo = VoxelEngineContexualCubeChunk.calculate_geometry(data, c, chunks_data, chunk_size, colors)
	call_deferred("_apply_result", c, geo)

func _apply_result(c: Vector3i, geo: Dictionary) -> void:
	if active_chunks.has(c):
		# Cast the node to the specific script class
		var chunk = active_chunks[c] as VoxelEngineContexualCubeChunk
		
		# Now Godot knows this node has the 'apply_geometry' function
		if chunk:
			chunk.apply_geometry(geo)
			if use_collision: 
				chunk.apply_collision(geo.verts)

func get_chunk_position(coords: Vector3i) -> Vector3:
	return Vector3(1.5*chunk_size*coords.x, chunk_size*coords.y, sqrt(3.0)*chunk_size*(coords.z+0.5*coords.x)) if use_hexagons else Vector3(coords)*chunk_size
