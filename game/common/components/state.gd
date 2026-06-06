class_name State
extends Node

signal finished(next_state_path: String, data: Object)

# ===
# Public
# ===

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_prev_state_path: String, _data: Object) -> void:
	pass

func exit() -> void:
	pass

# ===
# Private
# ===

func _get_assert_message(state_name: String, owner_name: String) -> String:
	return "{0} state must be owned by {1}.".format([state_name, owner_name])

func _subscribe_events() -> void: pass

func _unsubscribe_events() -> void: pass
