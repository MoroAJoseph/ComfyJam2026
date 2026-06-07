extends Control

# ===
# Signals
# ===

func _on_resume_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(Enums.PauseMenuAction.RESUME))

func _on_settings_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(Enums.PauseMenuAction.SETTINGS))

func _on_exit_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(Enums.PauseMenuAction.EXIT))

func _on_quit_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(Enums.PauseMenuAction.QUIT))
