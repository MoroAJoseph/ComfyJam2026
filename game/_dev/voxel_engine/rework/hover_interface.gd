class_name DEVVoxelEngineHoverInterface
extends Node

var build_context: DEVVoxelEngineBuildContext
var ray_length: float
var active_camera: Camera3D
var mouse_position: Vector2

# ===
# Node
# ===

func _init(
	p_build_context: DEVVoxelEngineBuildContext,
	p_ray_length: float
) -> void:
	build_context = p_build_context
	ray_length = p_ray_length
	print_debug("VoxelEngine: Hover Interface Created")

func _process(_delta: float) -> void:
	active_camera = get_viewport().get_camera_3d()
	if not active_camera: return
	
	mouse_position = get_viewport().get_mouse_position()
	_update_hover()

# ===
# Private
# ===

func _clear_hover_state() -> void:
	build_context.hovered_chunk_world_coordinate = Vector3i.ZERO
	build_context.hovered_voxel_local_coordinate = Vector3i.ZERO

func _update_hover() -> void:
	var from: Vector3 = active_camera.project_ray_origin(mouse_position)
	var to: Vector3 = from + active_camera.project_ray_normal(mouse_position) * ray_length
	var space_state: PhysicsDirectSpaceState3D = active_camera.get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		_handle_hover_result(result)
	else:
		_clear_hover_state()

func _handle_hover_result(result: Dictionary) -> void:
	var hit_rid: RID = result.rid
	var hit_pos: Vector3 = result.position
	var hit_normal: Vector3 = result.normal
	
	build_context.last_hovered_hit_rid = hit_rid 
	
	if build_context.rid_to_coordinate.has(hit_rid):
		_handle_voxel_hover(hit_pos, hit_normal)
	else:
		_clear_hover_state()

func _handle_voxel_hover(
	world_pos: Vector3, 
	hit_normal: Vector3
) -> void:
	var sample_pos: Vector3 = world_pos - (hit_normal * 0.1)
	var chunk_coord: Vector3i = build_context.rid_to_coordinate[build_context.last_hovered_hit_rid]
	var data: PackedByteArray = build_context.chunks_data[chunk_coord]
	var chunk_origin: Vector3i = build_context.voxel_class.chunk_to_world(
		chunk_coord, 
		build_context.chunk_size
	)
	var voxel_coord: Vector3i = build_context.voxel_class.world_to_local(
		sample_pos, 
		chunk_origin
	)
	build_context.hovered_chunk_world_coordinate = chunk_coord
	build_context.hovered_voxel_local_coordinate = voxel_coord
