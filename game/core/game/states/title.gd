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
			Constants.UI.MenuOption.MAIN, 
			true
		)
	)
	
	print_debug("TEMP: Leaving title in 1 second")
	get_tree().create_timer(1.0).timeout.connect(func(): _transition_to_world())

func exit() -> void:
	EventBus.emit(
		UIEvent.HideAllMenus.new()
	)
	_unsubscribe_events()

func _subscribe_events() -> void:
	EventBus.subscribe(UIEvent.MainMenu, _handle_ui_main_menu)
	
func _unsubscribe_events() -> void:
	EventBus.unsubscribe(UIEvent.MainMenu, _handle_ui_main_menu)

# ===
# Private
# ===

func _transition_to_world() -> void:
	_transition_to(
		StateName.LOAD, 
		GameLoadStateData.new(
			StateName.WORLD, 
		)
	)

# ===
# Signals
# ===

# --- UI ---
func _handle_ui_main_menu(event: UIEvent.MainMenu) -> void:
	match event.action:
		UIEvent.MainMenuAction.NEW:
			_transition_to_world()
		
		UIEvent.MainMenuAction.PLAY:
			_transition_to_world()
		
		UIEvent.MainMenuAction.EXIT:
			get_tree().quit()
