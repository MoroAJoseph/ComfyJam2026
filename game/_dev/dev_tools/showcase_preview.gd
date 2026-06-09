@tool
extends Node3D

@export var spacing: float = 2.0
@export var rotate_selected: bool = false
@export var rotation_speed: float = 1.5

# Export to toggle the editor gizmo for the selected node
@export var show_gizmo: bool = true:
	set(value):
		show_gizmo = value
		if _last_selected:
			_update_gizmo_visibility(_last_selected)

var _original_rotation: Vector3 = Vector3.ZERO
var _last_selected: Node3D = null

func _update_gizmo_visibility(node: Node3D):
	# In the editor, toggling the node's 'visible' state or 
	# locking/unlocking the node prevents gizmo interaction
	if show_gizmo:
		node.set_meta("_edit_lock_", false)
	else:
		node.set_meta("_edit_lock_", true)

func _enter_tree():
	if Engine.is_editor_hint():
		EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)

func _process(delta):
	if Engine.is_editor_hint() and rotate_selected and _last_selected:
		_last_selected.rotate_y(rotation_speed * delta)

func _on_selection_changed():
	var selection = EditorInterface.get_selection().get_selected_nodes()
	
	if _last_selected and is_instance_valid(_last_selected):
		_last_selected.rotation = _original_rotation
	
	if selection.size() > 0:
		var target = selection[0]
		if target.get_parent() == self and target is Node3D:
			_original_rotation = target.rotation
			_last_selected = target
			_update_gizmo_visibility(target) # Apply gizmo setting
			align_children(target)
		else:
			_last_selected = null
	else:
		_last_selected = null

func align_children(target: Node3D) -> void:
	var target_index = target.get_index()
	var children = get_children()
	for i in range(children.size()):
		if children[i] is Node3D:
			children[i].position.x = (i - target_index) * spacing
			children[i].update_gizmos()
