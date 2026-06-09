class_name UIHUDLayer
extends CanvasLayer

@onready var hud: Control = $HUD

var context: UIContext

# ===
# Built-In
# ===

func _ready() -> void:
	context = Session.ui_context
	toggle(false)
	visible = true

# ===
# Public
# ===

func toggle(is_open: bool) -> void:
	if hud:
		hud.visible = is_open
		context.is_hud_visible = is_open
