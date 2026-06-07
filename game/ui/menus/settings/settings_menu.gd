extends Control

# ===
# Signals
# ===

func _on_back_pressed() -> void:
	EventBus.emit(UIEvent.SettingsMenu.new(Enums.SettingsMenuAction.CLOSE))
