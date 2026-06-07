extends Control

# ===
# Built-In
# ===

func _ready() -> void:
	print_debug("ok ready")

# ===
# Signals
# ===

func _on_resume_pressed() -> void:
	print_debug("ok")
	EventBus.emit(UIEvent.PauseMenu.new(UIEvent.PauseMenuAction.RESUME))

func _on_settings_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(UIEvent.PauseMenuAction.SETTINGS))

func _on_exit_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(UIEvent.PauseMenuAction.EXIT))

func _on_quit_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(UIEvent.PauseMenuAction.QUIT))
