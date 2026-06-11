@tool
class_name UIUpgradeSectionFloatingHeader
extends MarginContainer

@export var title: String:
	set(value):
		if title == value: return # <--- CRITICAL: Prevents recursive loops
		title = value
		if is_node_ready(): 
			_update_title()

@export var icon: Texture2D:
	set(value):
		icon = value
		if is_node_ready(): 
			_update_icon()

@onready var upgrade_icon: TextureRect = %UpgradeIcon
@onready var title_label: Label = %Title

# ===
# Built-In
# ===

func _ready() -> void:
	set_header_info(title, icon)


func set_header_info(title_text: String, icon_tex: Texture2D) -> void:
	# Update internal variables only if they differ
	var changed := false
	
	if title != title_text:
		title = title_text
		changed = true
		
	if icon != icon_tex:
		icon = icon_tex
		changed = true
		
	# Only update the visual nodes if something actually changed
	# AND only if we are ready (to prevent Nil reference)
	if changed and is_node_ready():
		_update_title()
		_update_icon()

# ===
# Private
# ===

func _update_title() -> void:
	if title_label: title_label.text = title

func _update_icon() -> void:
	if upgrade_icon: upgrade_icon.texture = icon
