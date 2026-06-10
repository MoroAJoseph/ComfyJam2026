class_name NewVoxelEngineInteractor 
extends Node

@export var chunk_manager: NewVoxelEngineChunkManager
@export var highlighter: NewVoxelEngineHighlighter
@export var camera: Camera3D
@export var max_hover_distance: float = 100.0

var _current_hovered_chunk: Vector3i
var _current_hovered_voxel: Vector3i

# ===
# Built-In
# ===

func _process(_delta: float) -> void:
	var active_camera: Camera3D = camera if camera else get_viewport().get_camera_3d()
	if not active_camera or not chunk_manager: return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = active_camera.project_ray_origin(mouse_pos)
	var to = from + active_camera.project_ray_normal(mouse_pos) * max_hover_distance

	var space_state = active_camera.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))

	if result:
		_handle_hover(result)
	else:
		_clear_hover()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_block"):
		# Check if we have valid coordinates stored
		if _current_hovered_chunk != Vector3i.ZERO or _current_hovered_voxel != Vector3i.ZERO:
			chunk_manager.remove_voxel(_current_hovered_chunk, _current_hovered_voxel)
			_clear_hover()

# ===
# Private
# ===


func _handle_hover(result: Dictionary) -> void:
	if not chunk_manager.rid_to_coordinate.has(result.rid): 
		_clear_hover()
		return
	
	var coord = chunk_manager.rid_to_coordinate[result.rid]
	var chunk_origin = chunk_manager.logic_class.chunk_to_world(coord, chunk_manager.chunk_size)
	
	var sample_pos = result.position - (result.normal * 0.1)
	var local_voxel = chunk_manager.logic_class.world_to_local(sample_pos, chunk_origin)
	
	_current_hovered_chunk = coord
	_current_hovered_voxel = local_voxel
	
	if highlighter:
		var world_pos = chunk_manager.logic_class.voxel_to_world(local_voxel, chunk_origin)
		highlighter.update_highlight(world_pos, true)

func _clear_hover() -> void:
	_current_hovered_chunk = Vector3i.ZERO
	_current_hovered_voxel = Vector3i.ZERO
	if highlighter:
		highlighter.update_highlight(Vector3.ZERO, false)
