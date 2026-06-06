# Game
extends MainState

# ===
# Public
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	_subscribe_events()
	EventBus.emit(
		MainEvent.LoadGame.new()
	)

func exit() -> void:
	_unsubscribe_events()

func _subscribe_events() -> void:
	EventBus.subscribe(MainEvent.GameLoaded, _handle_main_game_loaded)

func _unsubscribe_events() -> void:
	EventBus.unsubscribe(MainEvent.GameLoaded, _handle_main_game_loaded)

# ===
# Private
# ===

# ===
# Signals
# ===

func _handle_main_game_loaded(_event: MainEvent.GameLoaded) -> void:
	print_debug("game loaded")
