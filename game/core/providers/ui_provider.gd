class_name UIProvider
extends ContextProvider

var context: UIContext

# ===
# Built-In
# ===

func _init(p_context: UIContext) -> void:
	context = p_context

# ===
# Public
# ===

func toggle_menu(option: Enums.MenuOption, is_visible: bool) -> void:
	if is_visible:
		if not context.open_menus.has(option):
			context.open_menus.append(option)
	else:
		context.open_menus.erase(option)
	
	context.open_menus_updated.emit(option)

func set_open_menus(value: Array[Enums.MenuOption]) -> void:
	context.open_menus = value
