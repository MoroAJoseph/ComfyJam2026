class_name GameSaveController
extends Node

@onready var _timer: Timer = $AutoSaveTimer

# ===
# Built-In
# ===

func _ready() -> void:
	if _timer:
		_timer.timeout.connect(_on_auto_save_timeout)

# ===
# Public API
# ===

func save_game() -> void:
	Session.save_provider.save_game()

func load_game(is_new_game: bool) -> void:
	Session.save_provider.load_game(is_new_game)

# ===
# Signals
# ===

func _on_auto_save_timeout() -> void:
	if Session.is_in_world:
		save_game()
