# World
extends GameState

# ===
# Built-In
# ===

func enter(_prev_state_path: String, _data: Object) -> void:
	print_debug("Game: Entered World")
	_subscribe_events()
	EventBus.emit(
		UIEvent.ToggleHUD.new(
			true
		)
	)

func exit() -> void:
	Context.session.is_in_world = false
	get_tree().paused = false
	EventBus.emit(
		UIEvent.ToggleHUD.new(
			false
		)
	)
	EventBus.emit(
		UIEvent.HideAllMenus.new()
	)
	_unsubscribe_events()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu_exit"):
		# Closing Menu
		if Context.ui.open_menus:
			EventBus.emit(
				UIEvent.HideAllMenus.new()
			)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		
		# Toggling Pause
		if get_tree().paused:
			_handle_resume()
		else:
			_handle_pause()

func _subscribe_events() -> void:
	EventBus.subscribe(UIEvent.PauseMenu, _handle_ui_pause_menu)
	EventBus.subscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)
	EventBus.subscribe(WorldEvent.DockEntered, _handle_dock_entered)
	EventBus.subscribe(WorldEvent.DockExited, _handle_dock_exited)

func _unsubscribe_events() -> void:
	EventBus.unsubscribe(UIEvent.PauseMenu, _handle_ui_pause_menu)
	EventBus.unsubscribe(UIEvent.SettingsMenu, _handle_ui_settings_menu)
	EventBus.unsubscribe(WorldEvent.DockEntered, _handle_dock_entered)
	EventBus.unsubscribe(WorldEvent.DockExited, _handle_dock_exited)

# ===
# Private
# ===

func _emit_toggle_pause_menu(is_paused: bool) -> void:
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			UIContext.MenuOption.PAUSE, 
			is_paused
		)
	)

func _emit_pause_updated(is_paused: bool) -> void:
	EventBus.emit(
		GameEvent.PausedUpdated.new(
			is_paused
		)
	)

func _toggle_pause(is_paused: bool) -> void:
	get_tree().paused = is_paused
	_emit_toggle_pause_menu(is_paused)
	_emit_pause_updated(is_paused)

func _handle_pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_toggle_pause(true)
	
func _handle_resume() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_toggle_pause(false)

# ===
# Event Handlers
# ===

# --- UI ---
func _handle_ui_pause_menu(event: UIEvent.PauseMenu) -> void:
	match event.action:
		UIEvent.PauseMenuAction.RESUME:
			_handle_resume()
		
		UIEvent.PauseMenuAction.SETTINGS:
			EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.PAUSE, false))
			EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.SETTINGS, true))
		
		UIEvent.PauseMenuAction.EXIT:
			_transition_to(
				StateName.LOAD, 
				GameLoadStateData.new(
					StateName.TITLE, 
				)
			)
		
		UIEvent.PauseMenuAction.QUIT:
			# CRITICAL: Warn player they are quitting with another menu
			get_tree().quit()

func _handle_ui_settings_menu(event: UIEvent.SettingsMenu) -> void:
	match event.action:
		UIEvent.SettingsMenuAction.BACK:
			EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.SETTINGS, false))
			if get_tree().paused:
				EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.PAUSE, true))
			else:
				EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.MAIN, true))

# --- World ---
func _handle_dock_entered(_event:WorldEvent.DockEntered) -> void:
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			UIContext.MenuOption.UPGRADES, 
			true
		)
	)

func _handle_dock_exited(_event:WorldEvent.DockExited) -> void:
	EventBus.emit(
		UIEvent.ToggleMenu.new(
			UIContext.MenuOption.UPGRADES, 
			false
		)
	)
