class_name StateMachine
extends Node

signal exited(state: State)
signal entered(state: State)

@export var initial_state: State

@onready var state: State = _get_initial_state()

# ===
# Built-In
# ===

func _ready() -> void:
	for child in get_children():
		if child is State:
			child.finished.connect(_transition_to_next_state)
	
	await owner.ready
	await get_tree().process_frame
	state.enter("", null)

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

# ===
# Public
# ===

func transition_to(target_state_path: String, data: Object = null) -> void:
	_transition_to_next_state(target_state_path, data)

# ===
# Private 
# ===

func _get_initial_state() -> State:
	if initial_state: return initial_state
	
	for child in get_children():
		if child is State: return child
	
	return null

func _transition_to_next_state(target_state_path: String, data: Object = null) -> void:
	if not has_node(target_state_path):
		printerr("[StateMachine] Cannot find state: ", target_state_path)
		return
	
	var prev_state: State = state
	var prev_state_path: String = state.name
	state.exit()
	exited.emit(prev_state)
	
	state = get_node(target_state_path)
	
	state.enter(prev_state_path, data)
	entered.emit(state)
