class_name UIDockMenu
extends Control

@export var icon: Texture2D:
	set(value):
		icon = value
		if is_node_ready():
			_update_icon()

@export var dock_name: String:
	set(value):
		dock_name = value
		if is_node_ready():
			_update_dock_name()

@export var dock_slogan: String:
	set(value):
		dock_slogan = value
		if is_node_ready():
			_update_dock_slogan()

# Header
@onready var dock_icon: TextureRect = %DockIcon
@onready var dock_name_label: Label = %DockName
@onready var dock_slogan_label: Label = %DockSlogan
@onready var gold_icon: TextureRect = %GoldIcon
@onready var current_gold: Label = %CurrentGold

# Sections
@onready var boat_upgrades_section: UIBoatUpgrades = %BoatUpgrades
@onready var tool_upgrades_section: UIToolUpgrades = %ToolUpgrades
@onready var selected_equipment: PanelContainer = %SelectedEquipment
@onready var market_trends: PanelContainer = %MarketTrends
@onready var sell_cargo: PanelContainer = %SellCargo
@onready var special_items: PanelContainer = %SpecialItems
@onready var advisor_s_note: PanelContainer = %"Advisor's Note"

# ===
# Built-In
# ===

func _ready() -> void:
	boat_upgrades_section.upgrade_item_selected.connect(_on_boat_upgrade_item_selected)
	tool_upgrades_section.upgrade_item_selected.connect(_on_tool_upgrade_item_selected)
	
	_update_icon()
	_update_dock_name()
	_update_dock_slogan()

# ===
# Private
# ===

func _update_icon() -> void:
	dock_icon.texture = icon

func _update_dock_name() -> void:
	dock_name_label.text = dock_name

func _update_dock_slogan() -> void:
	dock_slogan_label.text = dock_slogan

# ===
# Signals
# ===

func _on_boat_upgrade_item_selected(boat_type: Enums.BoatType) -> void:
	print_debug("Menu received: ", boat_type)

func _on_tool_upgrade_item_selected(tool_type: Enums.ToolType) -> void:
	print_debug("Menu received: ", tool_type)
