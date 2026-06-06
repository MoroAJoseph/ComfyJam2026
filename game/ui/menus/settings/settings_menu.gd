extends Control

@onready var _back_button: Button = %Back

# ===
# Built-In
# ===

func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)

# ===
# Signals
# ===

func _on_back_pressed() -> void:
	EventBus.emit(UIEvent.SettingsMenu.new(UIEvent.SettingsMenuAction.BACK))
