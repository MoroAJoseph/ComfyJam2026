# Load
extends GameState

var _enter_data: GameLoadStateData

# ===
# Built-In
# ===

func enter(_prev_state_path: String, data: Object) -> void:
	print_debug("Game: Entered Load")
	if not data is GameLoadStateData:
		push_error("LoadState: Invalid data")
		return
	
	_enter_data = data
	_subscribe_events()
	
	EventBus.emit(
		UIEvent.StartLoading.new()
	)
		
	match _enter_data.target_state:
		# Title
		GameState.StateName.TITLE:
			# Load Settings Save
			
			# Load Title
			EventBus.emit(
				GameEvent.LoadTitle.new()
			)
		
		# World
		GameState.StateName.WORLD:
			# Load Game Save
			var game_save_data: GameSaveData
			if _enter_data.is_new_game:
				game_save_data = Session.save_provider.load_new_game()
			else:
				game_save_data = Session.save_provider.load_game(_enter_data.save_game_file_path)
			
			if not game_save_data: 
				push_error("Game: Unable to load save. Returning to Title")
				EventBus.emit(
					GameEvent.LoadTitle.new()
				)
				return
			
			# Load World
			EventBus.emit(
				GameEvent.LoadWorld.new()
			)
		_:
			push_error("Game: Unable to load scene for next state. Returning to Title")
			EventBus.emit(
				GameEvent.LoadTitle.new()
			)

func exit() -> void:
	EventBus.emit(
		UIEvent.StopLoading.new()
	)
	_unsubscribe_events()

func _subscribe_events() -> void:
	EventBus.subscribe(GameEvent.TitleLoaded, _handle_game_scene_loaded)
	EventBus.subscribe(GameEvent.WorldLoaded, _handle_game_scene_loaded)

func _unsubscribe_events() -> void:
	EventBus.unsubscribe(GameEvent.TitleLoaded, _handle_game_scene_loaded)
	EventBus.unsubscribe(GameEvent.WorldLoaded, _handle_game_scene_loaded)

# ===
# Signals
# ===

func _handle_game_scene_loaded(_event: GameEvent) -> void:
	_transition_to(
		_enter_data.target_state, 
		_enter_data
	)
