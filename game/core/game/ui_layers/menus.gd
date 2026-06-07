class_name UIMenusLayer
extends CanvasLayer

@onready var main: Control = $MainMenu
@onready var pause: Control = $PauseMenu
@onready var settings: Control = $SettingsMenu
@onready var upgrades: Control = $UpgradeMenu

var menu_map: Dictionary[UIContext.MenuOption, Control]
var context: UIContext

# ===
# Built-In
# ===

func _ready() -> void:
	context = Context.ui
	menu_map = {
		UIContext.MenuOption.MAIN: main,
		UIContext.MenuOption.PAUSE: pause,
		UIContext.MenuOption.SETTINGS: settings,
		UIContext.MenuOption.UPGRADES: upgrades
	}
	
	hide_all()
	visible = true

# ===
# Public
# ===

func toggle(option: UIContext.MenuOption, is_open: bool) -> void:
	if menu_map.has(option):
		var menu: Control = menu_map.get(option, null)
		if not menu: return
		
		menu.visible = is_open
		context.open_menus = _get_open_menus()

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
	
	context.open_menus = _get_open_menus()

# ===
# Private
# ===

func _get_open_menus() -> Array[UIContext.MenuOption]:
	var open_options: Array[UIContext.MenuOption] = []
	for option in menu_map:
		var menu: Control = menu_map.get(option, null)
		if not menu: continue
		
		if menu.visible:
			open_options.append(option)
	
	return open_options
