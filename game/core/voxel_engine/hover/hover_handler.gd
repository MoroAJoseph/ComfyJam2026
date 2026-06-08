extends Node

## Reference to your chunk manager
@export var chunk_manager: VoxelEngineChunkManager
## Reference to the camera used for casting
@export var camera: Camera3D

const RAY_LENGTH = 100.0

func _process(_delta: float) -> void:
	var active_camera: Camera3D = camera if camera else get_viewport().get_camera_3d()
	
	if not active_camera or not chunk_manager:
		return

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = active_camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + active_camera.project_ray_normal(mouse_pos) * RAY_LENGTH

	var space_state: PhysicsDirectSpaceState3D = active_camera.get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	
	# Optional: Set collision mask to only hit chunks if needed
	# query.collision_mask = 1 

	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		var hit_rid: RID = result.rid
		var hit_pos: Vector3 = result.position
		var hit_normal: Vector3 = result.normal
		
		# Store the hit RID so the manager can look it up
		chunk_manager.last_hit_rid = hit_rid 
		
		if chunk_manager.rid_to_coordinate.has(hit_rid):
			_handle_voxel_hover(hit_pos, hit_normal)
	else:
		# Reset hover state if nothing is hit
		chunk_manager.hovered_chunk = Vector3i.ZERO
		chunk_manager.hovered_voxel = Vector3i.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_block"):
		if chunk_manager.highlight_mesh_instance.visible:
			var coord = chunk_manager.rid_to_coordinate[chunk_manager.last_hit_rid]
			play_block_destruction_animation(coord, chunk_manager.hovered_voxel)

func _handle_voxel_hover(world_pos: Vector3, hit_normal: Vector3) -> void:
	var coord = chunk_manager.rid_to_coordinate[chunk_manager.last_hit_rid]
	var data = chunk_manager.chunks_data[coord]
	var chunk_origin = chunk_manager.get_chunk_position(coord)
	
	var sample_pos = world_pos - (hit_normal * 0.1)
	var local_voxel = chunk_manager.logic_class.world_to_local(sample_pos, chunk_origin)
	
	# Generate the mesh specifically for this single voxel
	_update_highlight_geometry(local_voxel, data, coord)
	
	chunk_manager.highlight_mesh_instance.global_position = chunk_origin 
	chunk_manager.highlight_mesh_instance.visible = true

# Inside your Hover Handler script
func _update_highlight_geometry(voxel: Vector3i, data: PackedByteArray, coord: Vector3i) -> void:
	# Use pure white so the shader controls the colors
	var color = Color.WHITE 
	var geometry = chunk_manager.logic_class.get_single_voxel_geometry(
		voxel, data, coord, chunk_manager.chunks_data, chunk_manager.chunk_size, color
	)
	
	var mesh = ArrayMesh.new()
	if not geometry.verts.is_empty():
		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		surface_array[Mesh.ARRAY_VERTEX] = geometry.verts
		surface_array[Mesh.ARRAY_NORMAL] = geometry.norms
		surface_array[Mesh.ARRAY_COLOR] = geometry.cols
		surface_array[Mesh.ARRAY_TEX_UV] = geometry.uvs
		
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	chunk_manager.highlight_mesh_instance.mesh = mesh
	
	# Explicitly set the material override on the instance
	if chunk_manager.highlight_shader_material:
		chunk_manager.highlight_mesh_instance.material_override = chunk_manager.highlight_shader_material

func play_block_destruction_animation(chunk_coord: Vector3i, local_voxel: Vector3i) -> void:
	var chunk_pos = chunk_manager.get_chunk_position(chunk_coord)
	var target_pos = chunk_pos + Vector3(local_voxel)
	
	# Generate mock mesh
	var data = chunk_manager.chunks_data[chunk_coord]
	var geom = chunk_manager.logic_class.get_single_voxel_geometry(
		local_voxel, data, chunk_coord, chunk_manager.chunks_data, chunk_manager.chunk_size, Color.WHITE
	)
	if geom.is_empty(): return
	
	var temp_mesh = MeshInstance3D.new()
	chunk_manager.add_child(temp_mesh)
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = geom.verts
	surface_array[Mesh.ARRAY_NORMAL] = geom.norms
	surface_array[Mesh.ARRAY_COLOR] = geom.cols
	surface_array[Mesh.ARRAY_TEX_UV] = geom.uvs
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	temp_mesh.mesh = array_mesh
	temp_mesh.material_override = chunk_manager.highlight_shader_material
	temp_mesh.global_position = target_pos + (Vector3.UP * 0.05)
	
	# Trigger the logic change immediately
	chunk_manager.remove_voxel(chunk_coord, local_voxel)
	
	# Tween
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(temp_mesh, "scale", Vector3.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(temp_mesh, "rotation_degrees", Vector3(0, 180, 0), 0.3)
	
	# Cleanup after animation
	tween.tween_callback(temp_mesh.queue_free)
