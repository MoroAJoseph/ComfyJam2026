class_name Game
extends Node

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.emit(
		MainEvent.GameLoaded.new()
	)
