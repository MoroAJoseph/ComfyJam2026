@tool
class_name UIEquipmentUpgradeSection
extends PanelContainer

@export var equipment_upgrade_item_scene: PackedScene
@export var icon: Texture2D:
	set(value):
		icon = value
		if is_node_ready(): floating_header.set_header_info(header_title, icon)

@export var header_title: String = "Upgrades"
@onready var header: UIUpgradesOwnedHeader = %Header
@onready var floating_header: UIUpgradeSectionFloatingHeader = %FloatingHeader
@onready var items_container: VBoxContainer = %ItemsContainer

var upgrade_items: Dictionary = {}
var upgrade_button_group: ButtonGroup

func _ready() -> void:
	floating_header.set_header_info(header_title, icon)

func _update_owned_status_ui(ownership_status: Dictionary) -> void:
	var total = ownership_status.size()
	var count = ownership_status.values().filter(func(v): return v).size()
	header.set_counts(count, total)
	
	for item_key in upgrade_items:
		upgrade_items[item_key].visible = ownership_status.get(item_key, false)
