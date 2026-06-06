# Title
extends GameState

# ===
# Built-In
# ===

func enter(prev_state_path: String, _data: Object) -> void:
	print_debug("Game: Entered Title")


	if prev_state_path == "":
		print_debug("Game: Title -> Load")
		_transition_to(
			StateName.LOAD,
			GameLoadStateData.new(
				StateName.TITLE
			)
		)
		return
	
	_subscribe_events()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			UIContext.MenuOption.MAIN, 
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
		UIEvent.MainMenuAction.NEW:
			_transition_to_world(true)
		
		UIEvent.MainMenuAction.PLAY:
			_transition_to_world(false)
		
		UIEvent.MainMenuAction.SETTINGS:
			EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.MAIN, false))
			EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.SETTINGS, true))
		
		UIEvent.MainMenuAction.EXIT:
			get_tree().quit()

func _handle_ui_settings_menu(event: UIEvent.SettingsMenu) -> void:
	match event.action:
		UIEvent.SettingsMenuAction.BACK:
			EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.SETTINGS, false))
			EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.MAIN, true))
