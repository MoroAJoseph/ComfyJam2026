extends Control

# ===
# Signals
# ===

func _on_new_game_pressed() -> void:
	EventBus.emit(UIEvent.MainMenu.new(Enums.MainMenuAction.NEW))

func _on_play_pressed() -> void:
	EventBus.emit(UIEvent.MainMenu.new(Enums.MainMenuAction.PLAY))

func _on_settings_pressed() -> void:
	EventBus.emit(UIEvent.MainMenu.new(Enums.MainMenuAction.SETTINGS))

func _on_exit_pressed() -> void:
	EventBus.emit(UIEvent.MainMenu.new(Enums.MainMenuAction.EXIT))
