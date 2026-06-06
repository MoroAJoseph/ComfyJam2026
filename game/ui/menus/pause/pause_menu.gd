extends Control

@onready var _resume_button: Button = %Resume
@onready var _settings_button: Button = %Settings
@onready var _exit_button: Button = %Exit
@onready var _quit_button: Button = %Quit

# ===
# Built-In
# ===

func _ready() -> void:
	_resume_button.pressed.connect(_on_resume_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_exit_button.pressed.connect(_on_exit_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

# ===
# Signals
# ===

func _on_resume_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(UIEvent.PauseMenuAction.RESUME))

func _on_settings_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(UIEvent.PauseMenuAction.SETTINGS))

func _on_exit_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(UIEvent.PauseMenuAction.EXIT))

func _on_quit_pressed() -> void:
	EventBus.emit(UIEvent.PauseMenu.new(UIEvent.PauseMenuAction.QUIT))
