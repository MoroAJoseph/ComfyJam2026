extends Node3D

func _ready() -> void:
	# Force the session flag to true so the TimeController runs in this preview
	Context.session.is_in_world = true
	print_debug("Sky Preview: Session initialized. Day duration is ", Constants.DAY_DURATION, "s")
