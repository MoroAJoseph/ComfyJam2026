class_name Bootsplash
extends Node

# TODO: Bootsplash

# ===
# Built-In
# ===

func _ready() -> void:
	get_tree().create_timer(1.0).timeout.connect(_on_timer_timeout)

# ===
# Signals
# ===

func _on_timer_timeout() -> void:
	EventBus.emit(
		MainEvent.BootsplashLoaded.new()
	)
