class_name UIContext
extends RefCounted

enum MenuOption {
	MAIN,
	PAUSE,
	SETTINGS,
}
	
var is_loading := false
var open_menus : Array[MenuOption] = []
var is_hud_visible := false
