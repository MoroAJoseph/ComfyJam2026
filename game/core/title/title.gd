class_name Title
extends Node3D

# TODO: Title level

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.emit(
		GameEvent.TitleLoaded.new()
	)
	
