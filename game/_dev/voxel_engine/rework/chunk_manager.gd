class_name DEVVoxelEngineChunkManager
extends Node3D

var build_context: DEVVoxelEngineBuildContext

var active_chunks: Dictionary[Vector3i, Dictionary] = {}
var dirty_chunks: Dictionary[Vector3i, bool] = {}
var loading_chunks: Array[Vector3i] = []

# ===
# Built-In
# ===

func _init(
	p_build_context: DEVVoxelEngineBuildContext
) -> void:
	build_context = p_build_context
	print_debug("VoxelEngine: ChunkManager Created")

func _process(_delta: float) -> void:
	# Dirty Chunks
	if not dirty_chunks.is_empty():
		var chunk_coord: Vector3i = dirty_chunks.keys()[0]
		_process_chunk_geometry(
			chunk_coord, 
			build_context.chunks_data[chunk_coord]
		)

# ===
# Public
# ===

func update_rendered_chunks(
	render_radius: int
) -> void:
	var needed_coordinates: Array[Vector3i] = []
	
	# Get Relative Chunks
	for x: int in range(-render_radius, render_radius + 1):
		for z: int in range(-render_radius, render_radius + 1):
			if Vector2(x, z).length() <= render_radius:
				needed_coordinates.append(build_context.current_player_chunk + Vector3i(x, 0, z))
	
	# Spawn Active Chunks
	for coordinate: Vector3i in needed_coordinates:
		if not (
			active_chunks.has(coordinate) and 
			build_context.chunks_data.has(coordinate)
		):
			_spawn_chunk(coordinate)
	
	# Remove Unneeded Chunks
	for coordinate: Vector3i in active_chunks.keys().duplicate():
		if not coordinate in needed_coordinates:
			_remove_chunk(coordinate)
	
# ===
# Private
# ===

func _spawn_chunk(coordinate: Vector3i) -> void:
	if loading_chunks.has(coordinate): return
		
	loading_chunks.append(coordinate)
	
	var mesh_rid: RID = RenderingServer.mesh_create()
	var instance_rid: RID = RenderingServer.instance_create()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	
	material.vertex_color_use_as_albedo = true
	
	RenderingServer.instance_set_base(
		instance_rid, 
		mesh_rid
	)
	RenderingServer.instance_geometry_set_material_override(
		instance_rid, 
		material.get_rid()
	)
	RenderingServer.instance_set_scenario(
		instance_rid, 
		get_world_3d().scenario
	)
	RenderingServer.instance_set_transform(
		instance_rid,
		Transform3D(
			Basis(), 
			build_context.voxel_class.chunk_to_world(
				coordinate, 
				build_context.chunk_size
			)
		)
	)

	active_chunks[coordinate] = {
		"mesh": mesh_rid,
		"instance": instance_rid,
		"material": material,
		"body": RID(),
		"shape": RID()
	}
	
	WorkerThreadPool.add_task(
		func() -> void: 
			_process_chunk_geometry(
				coordinate, 
				build_context.chunks_data[coordinate]
			)
	)

func _remove_chunk(coordinate: Vector3i) -> void:
	var chunk: Dictionary = active_chunks[coordinate]

	RenderingServer.free_rid(chunk.instance)
	RenderingServer.free_rid(chunk.mesh)

	if chunk.body.is_valid():
		PhysicsServer3D.free_rid(chunk.body)

	if chunk.shape.is_valid():
		PhysicsServer3D.free_rid(chunk.shape)

	#rid_to_coordinate.erase(chunk.body)
	active_chunks.erase(coordinate)

func _process_chunk_geometry(
	coord: Vector3i, 
	data: PackedByteArray,
) -> void:
	var geometry: Dictionary = build_context.voxel_class.calculate_geometry(
		data,
		coord,
		build_context.chunks_data,
		build_context.chunk_size,
		build_context.voxel_colors
	)

	call_deferred(
		"_apply_result", 
		coord, 
		geometry
	)

func _apply_chunk_geometry(
	coordinate: Vector3i, 
	geometry: Dictionary
) -> void:
	loading_chunks.erase(coordinate)
	if not active_chunks.has(coordinate): return
	
	var chunk: Dictionary = active_chunks[coordinate]
	RenderingServer.mesh_clear(chunk.mesh)
	
	# Only create a surface if we actually have vertices
	if not geometry.vertices.is_empty():
		var surface_array: Array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		surface_array[Mesh.ARRAY_VERTEX] = geometry.vertices
		surface_array[Mesh.ARRAY_NORMAL] = geometry.normals
		surface_array[Mesh.ARRAY_COLOR] = geometry.colors
		
		RenderingServer.mesh_add_surface_from_arrays(
			chunk.mesh, RenderingServer.PRIMITIVE_TRIANGLES, surface_array
		)
	
	# Update Physics
	if chunk.body.is_valid():
		build_context.rid_to_coordinate.erase(chunk.body)
		PhysicsServer3D.free_rid(chunk.body)
		chunk.body = RID()
	
	if not geometry.vertices.is_empty():
		chunk.body = PhysicsServer3D.body_create()
		PhysicsServer3D.body_set_mode(
			chunk.body, 
			PhysicsServer3D.BODY_MODE_STATIC
		)
		PhysicsServer3D.body_set_space(
			chunk.body, 
			get_world_3d().space
		)
		
		# CRITICAL TODO: Pass through Root
		PhysicsServer3D.body_set_collision_layer(chunk.body, 1)
		PhysicsServer3D.body_set_collision_mask(chunk.body, 1)

		var shape_rid: RID = PhysicsServer3D.concave_polygon_shape_create()
		PhysicsServer3D.shape_set_data(
			shape_rid, 
			{
				"faces": geometry.vertices, 
				"backface_collision": false
			}
		)
		
		PhysicsServer3D.body_add_shape(chunk.body, shape_rid)
		PhysicsServer3D.body_set_state(
			chunk.body,
			PhysicsServer3D.BODY_STATE_TRANSFORM,
			Transform3D(
				Basis(), 
				build_context.voxel_class.chunk_to_world(
					coordinate, 
					build_context.chunk_size
				)
			)
		)
		
		build_context.rid_to_coordinate[chunk.body] = coordinate
		chunk.shape = shape_rid
