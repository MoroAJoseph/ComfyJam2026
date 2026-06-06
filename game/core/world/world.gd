class_name World
extends Node3D


var context: WorldContext

# ===
# Built-In
# ===

func _ready() -> void:
	context = Context.world
	
	EventBus.emit(
		GameEvent.WorldLoaded.new()
	)
