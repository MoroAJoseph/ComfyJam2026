class_name UIEvent
extends Event

class StartLoading extends UIEvent: pass
class StopLoading extends UIEvent: pass
class HideAllMenus extends UIEvent: pass

class ToggleMenu extends UIEvent:
	
	var option: Enums.MenuOption
	var is_visible: bool
	
	func _init(
		p_option: Enums.MenuOption, 
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
class MainMenu extends UIEvent:
	
	var action: Enums.MainMenuAction
	
	func _init(
		p_action: Enums.MainMenuAction
	) -> void:
		action = p_action

# ===
# World Menu
# ===

# --- Pause ---
class PauseMenu extends UIEvent:
	
	var action: Enums.PauseMenuAction
	
	func _init(
		p_action: Enums.PauseMenuAction
	) -> void:
		action = p_action

# --- Settings ---
class SettingsMenu extends UIEvent:
	
	var action: Enums.SettingsMenuAction
	
	func _init(
		p_action: Enums.SettingsMenuAction
	) -> void:
		action = p_action

# --- Dock ---
class DockMenu extends UIEvent:
	
	var action: Enums.DockMenuAction
	
	func _init(
		p_action: Enums.DockMenuAction
	) -> void:
		action = p_action
