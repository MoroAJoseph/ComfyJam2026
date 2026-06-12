@tool
class_name UIDockMenuSelectedEquipmentStatItem
extends MarginContainer

@export var stat_icon: Texture2D
@export var stat_name: String = "Stat"
@export_range(1, 5, 1) var level: int
@export var difference: int

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var levels_container: HBoxContainer = %Levels
@onready var difference_label: Label = %Difference

var levels: Array[UIEquipmentStatLevelItem] = []

func _ready() -> void:
	for child in levels_container.get_children():
		if child is UIEquipmentStatLevelItem:
			levels.append(child)
	
	_update_icon()
	_update_name()
	_update_level()
	_update_difference()

func _update_icon() -> void:
	icon.texture = stat_icon

func _update_name() -> void:
	name_label.text = stat_name

func _update_level() -> void:
	pass

func _update_difference() -> void:
	pass
