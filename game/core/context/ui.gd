class_name UIContext
extends ContextData

enum Var { 
	
}

const DEFAULT: Dictionary[Var, Variant] = {

}

# ===
# Runtime
# ===

# --- Screen Resolution ---
signal screen_resolution_updated(value: Vector2)
var _screen_resolution: Vector2
var screen_resolution: Vector2:
	get: return _screen_resolution
	set(value):
		if _authorize_write():
			_screen_resolution = value
			screen_resolution_updated.emit(value)

# --- Open Menus ---
signal open_menus_updated(value: Enums.MenuOption)
var _open_menus: Array[Enums.MenuOption] = []
var open_menus: Array[Enums.MenuOption]:
	get: return _open_menus
	set(value):
		if _authorize_write():
			_open_menus = value
			open_menus_updated.emit(value)

# --- HUD Visibility ---
signal loading_udpated(value: bool)
var _is_loading: bool
var is_loading: bool:
	get: return _is_loading
	set(value):
		_is_loading = value
		loading_udpated.emit(value)

# --- HUD Visibility ---
signal hud_visibility_updated(value: bool)
var _is_hud_visible: bool
var is_hud_visible: bool:
	get: return _is_hud_visible
	set(value):
		_is_hud_visible = value
		hud_visibility_updated.emit(value)

# TODO: Loading screen

# ===
# Persistent
# ===

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	_screen_resolution = Vector2.ZERO
	_open_menus.clear()
	open_menus_updated.emit(open_menus)
	_is_loading = false
	_is_hud_visible = false
