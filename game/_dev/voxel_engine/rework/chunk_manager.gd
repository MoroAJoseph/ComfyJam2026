class_name ChunkManager extends Node

@export var chunk_size: int = 32
@export var meshing_algorithm: MeshingAlgorithm
@export var terrain_algorithm: TerrainAlgorithm
@export var logger: ChunkManagerLogger = ChunkManagerLogger.new()

var chunk_class = preload("res://_dev/voxel_engine/rework/chunk.tscn")
var chunks: Dictionary[Vector3i, Chunk] = {}

func _ready()-> void:
	logger.chunk_manager = self
	logger.enable_logging(self)

func add_voxel(world_pos: Vector3, voxel: TerrainAlgorithm.Voxel) -> void:
	if !meshing_algorithm or !meshing_algorithm.ScriptGeometry: return
	var geom = meshing_algorithm.ScriptGeometry
	
	# Let the assigned shape figure out its grid array coordinate indices
	var grid_pos = geom.WorldToGridPosition(world_pos)
	var chunk_position = voxel_to_chunk_position(grid_pos)
	
	var chunk = chunks.get(chunk_position)
	if !chunk:
		chunk = create_chunk(chunk_position)
		add_child(chunk)
	
	var local_position = global_to_local(grid_pos)
	chunk.chunk_data.AddVoxel(local_position.x, local_position.y, local_position.z, voxel)
	chunk.remesh()
	
func remove_voxel(world_pos: Vector3) -> void:
	if !meshing_algorithm or !meshing_algorithm.ScriptGeometry: return
	var geom = meshing_algorithm.ScriptGeometry
	
	var grid_pos = geom.WorldToGridPosition(world_pos)
	var chunk_position = voxel_to_chunk_position(grid_pos)
	
	var chunk = chunks.get(chunk_position)
	if !chunk: return
	
	var local_position = global_to_local(grid_pos)	
	chunk.chunk_data.RemoveVoxel(local_position.x, local_position.y, local_position.z)
	
	if chunk.chunk_data.IsEmpty():
		remove_chunk(chunk_position)
		return
		
	chunk.remesh()

func get_chunk(pos: Vector3i) -> Chunk:
	var chunk_position = voxel_to_chunk_position(pos)
	if !chunks.has(chunk_position): return null
	return chunks[chunk_position]
	
func remove_chunk(chunk_position: Vector3i) -> void:
	if !chunks.has(chunk_position): return
	var chunk = chunks[chunk_position]
	chunks.erase(chunk_position)
	chunk.queue_free()
	
func create_chunk(chunk_position: Vector3i) -> Chunk:
	remove_chunk(chunk_position)
	var chunk = chunk_class.instantiate() as Chunk
	chunk.chunk_data.SetSize(chunk_size)
	chunk.meshing_algorithm = meshing_algorithm
	chunk.position = chunk_position
	chunks[chunk.position] = chunk
	return chunk
	
func generate_chunk(chunk_grid_index: Vector3i) -> void:
	var world_origin = get_chunk_world_origin(chunk_grid_index)
	var chunk = create_chunk(world_origin)
	
	chunk.generate_data(terrain_algorithm)
	if chunk.chunk_data.IsEmpty():
		remove_chunk(chunk.position)
		return
	
	logger.start_time_log()
	chunk.create_mesh()
	logger.end_time_log(chunk, chunk_grid_index)
	call_deferred("add_child", chunk)

# --- GRID TRANSFORM HELPER COUPLING FIXES ---

func get_chunk_world_origin(chunk_grid_index: Vector3i) -> Vector3i:
	if meshing_algorithm and meshing_algorithm.ScriptGeometry and meshing_algorithm.ScriptGeometry.has_method("GetWorldPosition"):
		var internal_target = chunk_grid_index * chunk_size
		var calculated_origin = meshing_algorithm.ScriptGeometry.GetWorldPosition(internal_target)
		return Vector3i(calculated_origin.round())
	return chunk_grid_index * chunk_size

func global_to_local(pos: Vector3i) -> Vector3i:
	# Wraps negative remainders cleanly back into the positive 0 to 31 space
	var local_x = pos.x % chunk_size
	var local_y = pos.y % chunk_size
	var local_z = pos.z % chunk_size
	return Vector3i(
		local_x + chunk_size if local_x < 0 else local_x,
		local_y + chunk_size if local_y < 0 else local_y,
		local_z + chunk_size if local_z < 0 else local_z
	)

func voxel_to_chunk_position(pos: Vector3i) -> Vector3i:
	# Using float conversion + floor ensures -15 / 32 rounds down to -1, mapping to -32
	var grid_x = floor(pos.x / float(chunk_size)) as int
	var grid_y = floor(pos.y / float(chunk_size)) as int
	var grid_z = floor(pos.z / float(chunk_size)) as int
	return Vector3i(grid_x, grid_y, grid_z) * chunk_size
