# Title
extends GameState

# ===
# Built-In
# ===

func enter(prev_state_path: String, _data: Object) -> void:
	print_debug("Game: Entered Title")
	
	# Enter loading on first load
	if prev_state_path == "":
		print_debug("Game: Title -> Load")
		_transition_to(
			StateName.LOAD,
			GameLoadStateData.new(
				StateName.TITLE
			)
		)
		return
	
	# handle normally
	_subscribe_events()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			Enums.MenuOption.MAIN, 
			true
		)
	)

func exit() -> void:
	EventBus.emit(
		UIEvent.HideAllMenus.new()
	)
	_unsubscribe_events()

func _subscribe_events() -> void:
	EventBus.subscribe(UIEvent.MainMenu, _handle_ui_main_menu)
	EventBus.subscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)
	
func _unsubscribe_events() -> void:
	EventBus.unsubscribe(UIEvent.MainMenu, _handle_ui_main_menu)
	EventBus.unsubscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)

# ===
# Private
# ===

func _transition_to_world(is_new_game: bool) -> void:
	_transition_to(
		StateName.LOAD, 
		GameLoadStateData.new(
			StateName.WORLD, 
			is_new_game
		)
	)

# ===
# Signals
# ===

# --- UI ---
func _handle_ui_main_menu(event: UIEvent.MainMenu) -> void:
	match event.action:
		Enums.MainMenuAction.NEW:
			_transition_to_world(true)
		
		Enums.MainMenuAction.PLAY:
			_transition_to_world(false)
		
		Enums.MainMenuAction.SETTINGS:
			# Close Main
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuOption.MAIN, 
					false
				)
			)
			# Open Settings
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuOption.SETTINGS, 
					true
				)
			)
		
		Enums.MainMenuAction.EXIT:
			get_tree().quit()

func _handle_ui_settings_menu(event: UIEvent.SettingsMenu) -> void:
	match event.action:
		Enums.SettingsMenuAction.CLOSE:
			# Close Settings
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuOption.SETTINGS, 
					false
				)
			)
			
			# Open Main
			EventBus.emit(
				UIEvent.ToggleMenu.new(
					Enums.MenuOption.MAIN, 
					true
				)
			)
