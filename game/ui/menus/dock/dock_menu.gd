class_name UIDockMenu
extends Control

@onready var dock_icon: TextureRect = %DockIcon
@onready var dock_name: Label = %DockName
@onready var dock_slogan: Label = %DockSlogan
@onready var boat_upgrades: UIBoatUpgrades = %BoatUpgrades
@onready var tool_upgrades: PanelContainer = %ToolUpgrades

# ===
# Built-In
# ===

func _ready() -> void:
	boat_upgrades.upgrade_item_selected.connect(_on_boat_upgrade_item_selected)

# ===
# Private
# ===


# ===
# Signals
# ===

func _on_boat_upgrade_item_selected(boat_type: Enums.BoatType) -> void:
	print_debug("Menu received: ", boat_type)
