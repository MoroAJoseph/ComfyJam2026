class_name UIMenusLayer
extends CanvasLayer

@onready var main: Control = $MainMenu
@onready var pause: Control = $PauseMenu
@onready var settings: Control = $SettingsMenu
@onready var dock: Control = $DockMenu

var menu_map: Dictionary[Enums.MenuOption, Control]

# ===
# Built-In
# ===

func _ready() -> void:
	menu_map = {
		Enums.MenuOption.MAIN: main,
		Enums.MenuOption.PAUSE: pause,
		Enums.MenuOption.SETTINGS: settings,
		Enums.MenuOption.DOCK: dock
	}
	
	hide_all()
	visible = true

# ===
# Public
# ===

func toggle(option: Enums.MenuOption, is_open: bool) -> void:
	if menu_map.has(option):
		var menu: Control = menu_map.get(option, null)
		if not menu: return
		
		menu.visible = is_open
		
		Session.ui_provider.set_open_menus(_get_open_menus())

func has_any_open() -> bool:
	for option in menu_map:
		var menu: Control = menu_map.get(option, null)
		if not menu: continue
		
		return menu.visible
	
	return false

func hide_all() -> void:
	for menu in menu_map.values():
		if menu:
			menu.hide()
	
	Session.ui_provider.set_open_menus(_get_open_menus())

# ===
# Private
# ===

func _get_open_menus() -> Array[Enums.MenuOption]:
	var open_options: Array[Enums.MenuOption] = []
	for option in menu_map:
		var menu: Control = menu_map.get(option, null)
		if not menu: continue
		
		if menu.visible:
			open_options.append(option)
	
	return open_options
