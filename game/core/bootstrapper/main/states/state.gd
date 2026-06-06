class_name MainState
extends State

enum StateName { BOOT, GAME }

var _owner: Main

# ===
# Built-In
# ===

func _ready() -> void:
	await owner.ready
	
	_owner = owner as Main

# ===
# Public
# ===

func get_state_name(state: StateName) -> String:
	return StateName.keys()[state].capitalize()

# ===
# Private
# ===

func _transition_to(state: StateName, data: Object) -> void:
	finished.emit(get_state_name(state), data)
