class_name UILoadingLayer
extends CanvasLayer

@onready var icon: Control = $LoadingIcon
@onready var screen: Control = $LoadingScreen

var context: UIContext

# ===
# Built-In
# ===

func _ready() -> void:
	context = Context.ui
	show()
	if screen:
		screen.hide()

# ===
# Public
# ===

func start() -> void:
	if screen:
		screen.show()
		context.is_loading = true

func stop() -> void:
	hide()
	context.is_loading = false
