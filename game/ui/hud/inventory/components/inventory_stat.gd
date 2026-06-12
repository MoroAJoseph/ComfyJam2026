@tool
class_name UIHUDInventoryStat
extends HBoxContainer

@export var stat_icon: Texture2D:
	set(value):
		stat_icon = value
		if is_node_ready(): 
			_update_icon()
@export var fill_color: Color:
	set(value):
		fill_color = value
		if is_node_ready():
			_update_bar_color()
@export var current_value: int:
	set(value):
		current_value = clampi(value, 0, max_value)
		if is_node_ready(): 
			_update_current()
			_update_bar_values()
@export var max_value: int:
	set(value):
		max_value = max(value, 1) # Prevent division by zero
		if current_value > max_value:
			current_value = max_value
		if is_node_ready(): 
			_udpate_max()
			_update_bar_values()

@onready var icon: TextureRect = %Icon
@onready var current_value_label: Label = %Current
@onready var max_value_label: Label = %Max
@onready var bar: ProgressBar = %Bar

var tween: Tween

# ===
# Built-In
# ===

func _ready() -> void:
	_update_all()

# ===
# Private
# ===

func _update_all() -> void:
	_update_icon()
	_update_current()
	_udpate_max()
	_update_bar_values()
	_update_bar_color()

func _update_icon() -> void: 
	if icon: 
		icon.texture = stat_icon

func _update_current() -> void: 
	if current_value_label: 
		current_value_label.text = str(current_value)

func _udpate_max() -> void: 
	if max_value_label: 
		max_value_label.text = str(max_value)

func _update_bar_values() -> void:
	if not bar: return
	
	bar.max_value = float(max_value)
	
	# Skip tween if the new max forces a snap
	if bar.value > bar.max_value:
		if tween: tween.kill()
		bar.value = float(current_value)
		return

	var target_value: float = float(current_value)
	
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(bar, "value", target_value, 0.3).set_trans(Tween.TRANS_CUBIC)

func _update_bar_color() -> void:
	if not bar: return
	
	var style: StyleBox = bar.get_theme_stylebox("fill")
	
	if style is StyleBoxFlat:
		var new_style: StyleBoxFlat = style.duplicate()
		new_style.bg_color = fill_color
		bar.add_theme_stylebox_override("fill", new_style)
