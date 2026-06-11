@tool
class_name UIEquipmentStatItem
extends MarginContainer

@export var stat_name: String = "Stat":
	set(value):
		stat_name = value
		if is_node_ready(): _update_stat_name()

@export_range(0, 5, 1) var level: int = 0:
	set(value):
		level = value
		if is_node_ready(): _update_levels()

@onready var stat_name_label: Label = %StatName
@onready var levels: HBoxContainer = %Levels

var level_items: Array[UIEquipmentStatLevelItem] = []

# ===
# Built-In
# ===

func _ready() -> void:
	# Cache level items
	level_items.clear()
	for child in levels.get_children():
		if child is UIEquipmentStatLevelItem:
			level_items.append(child)
	
	_update_stat_name()
	_update_levels()

# ===
# Private
# ===

func _update_stat_name() -> void:
	if stat_name_label:
		stat_name_label.text = stat_name

func _update_levels() -> void:
	if level_items.is_empty():
		return

	for i in range(level_items.size()):
		level_items[i].is_filled = (i < level)
