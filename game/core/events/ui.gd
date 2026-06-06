class_name UIEvent
extends Event

class StartLoading extends UIEvent: pass
class StopLoading extends UIEvent: pass
class HideAllMenus extends UIEvent: pass

class ToggleMenu extends UIEvent:
	
	var option: Constants.UI.MenuOption
	var is_visible: bool
	
	func _init(
		p_option: Constants.UI.MenuOption, 
		p_is_visible: bool
	):
		option = p_option
		is_visible = p_is_visible

class ToggleHUD extends UIEvent:
	
	var is_visible: bool
	
	func _init(
		p_is_visible: bool
	):
		is_visible = p_is_visible

# ===
# Title Menu
# ===

# --- Main ---
enum MainMenuAction { OPEN, CLOSE, NEW, PLAY, EXIT, SETTINGS }

class MainMenu extends UIEvent:
	
	var action: MainMenuAction
	
	func _init(
		p_action: MainMenuAction
	) -> void:
		action = p_action

# ===
# World Menu
# ===

# --- Pause ---
enum PauseMenuAction { OPEN, CLOSE, RESUME, SETTINGS, EXIT, QUIT }

class PauseMenu extends UIEvent:
	
	var action: PauseMenuAction
	
	func _init(
		p_action: PauseMenuAction
	) -> void:
		action = p_action
