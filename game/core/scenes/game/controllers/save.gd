class_name GameSaveController
extends Node

@onready var _timer: Timer = $AutoSaveTimer

var settings_data: SettingsSaveData
var game_data: GameSaveData

# ===
# Built-In
# ===

func _ready() -> void:
	settings_data = Session.save_provider.load_settings(Constants.Paths.Data.USER_SETTINGS_SAVE)
	
	if _timer:
		_timer.timeout.connect(_on_auto_save_timeout)
	
	_subscribe()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Public
# ===

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(GameEvent.SaveSettings, _handle_game_save_settings)

func _unsubscribe() -> void:
	EventBus.unsubscribe(GameEvent.SaveSettings, _handle_game_save_settings)

# ===
# Event Handlers 
# ===

func _handle_game_save_settings(_event: GameEvent.SaveSettings) -> void:
	print_debug("Saving Settings Data")
	Session.save_provider.save_settings(settings_data)

# ===
# Signals
# ===

func _on_auto_save_timeout() -> void:
	if game_data and Session.is_in_world:
		Session.save_provider.save_game(game_data, true)
