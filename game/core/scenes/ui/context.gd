class_name UIContext
extends ContextData

enum Var {
	GUI_SCALE
}

const DEFAULT: Dictionary[Var, Variant] = {
	Var.GUI_SCALE: Enums.GUIScale.FULL
}

# ===
# Runtime
# ===

# --- Screen Resolution ---
signal screen_resolution_updated(value: Vector2)
var screen_resolution: Vector2:
	set(value):
		screen_resolution = value
		screen_resolution_updated.emit(value)

# --- Open Menus ---
signal open_menus_updated(value: Enums.MenuOption)
var open_menus: Array[Enums.MenuOption] = []

# --- Flags ---
var is_loading: bool
var is_hud_visible: bool

# ===
# Persistent
# ===

# --- GUI Scale ---
signal gui_scale_updated(value: Enums.GUIScale)
var gui_scale: Enums.GUIScale:
	set(value):
		gui_scale = value
		gui_scale_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	# Runtime
	screen_resolution = Vector2.ZERO
	open_menus.clear()
	open_menus_updated.emit(open_menus)
	is_loading = false
	is_hud_visible = false
	
	# Persistent
	gui_scale = DEFAULT[Var.GUI_SCALE] as Enums.GUIScale

func to_dict() -> Dictionary[int, Variant]:
	return {
		Var.GUI_SCALE: gui_scale
	}

func from_dict(data: Dictionary[int, Variant]) -> void:
	gui_scale = data.get(Var.GUI_SCALE, DEFAULT[Var.GUI_SCALE]) as Enums.GUIScale

# ===
# Public
# ===

func toggle_menu(option: Enums.MenuOption, is_visible: bool) -> void:
	if is_visible:
		if not open_menus.has(option):
			open_menus.append(option)
	else:
		open_menus.erase(option)
	
	open_menus_updated.emit(option)
