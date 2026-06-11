@tool
class_name UIEquipmentUpgradeItem
extends MarginContainer

signal pressed

@export var equipment_stat_item_scene: PackedScene
@export var icon: Texture2D:
	set(value):
		icon = value
		if is_node_ready(): _update_icon()
@export var item_name: String:
	set(value):
		item_name = value
		if is_node_ready(): _update_name()
@export var buy_price: int:
	set(value):
		buy_price = value
		if is_node_ready(): _update_buy_price()
@export var stats: Dictionary = {}:
	set(value):
		stats = value
		if is_initialized: _update_stats()

@onready var icon_rect: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var price_label: Label = %BuyPrice
@onready var stat_container: VBoxContainer = %StatItems
@onready var button: Button = %Button

var stat_items_cache: Dictionary = {}
var is_initialized: bool = false

func _ready() -> void:
	button.pressed.connect(func(): pressed.emit())
	_rebuild_stat_cache()
	is_initialized = true
	_update_all()

func _rebuild_stat_cache() -> void:
	for child in stat_container.get_children(): child.queue_free()
	stat_items_cache.clear()
	_update_stats()

func _update_all() -> void:
	_update_icon(); _update_name(); _update_buy_price(); _update_stats()

func _update_icon() -> void: if icon_rect: icon_rect.texture = icon
func _update_name() -> void: if name_label: name_label.text = item_name
func _update_buy_price() -> void: if price_label: price_label.text = str(buy_price)

func _update_stats() -> void:
	if not is_initialized: return
	for stat_key in stats:
		var item = equipment_stat_item_scene.instantiate() as UIEquipmentStatItem
		stat_container.add_child(item)
		stat_items_cache[stat_key] = item
		item.stat_name = str(stat_key).capitalize()
		item.level = stats[stat_key]

func _setup_upgrade_item(data: BoatData, type: int, group: ButtonGroup, parent: UIBoatUpgrades) -> void:
	if button:
		button.button_group = group
	
	if not pressed.is_connected(parent._on_upgrade_item_pressed):
		pressed.connect(parent._on_upgrade_item_pressed.bind(type))
		
	item_name = data.display_name
	buy_price = data.buy_price
	
	var stats_dict = {}
	for boat_stat in Enums.BoatStat.values():
		stats_dict[boat_stat] = data.get_stat(boat_stat)
	stats = stats_dict
