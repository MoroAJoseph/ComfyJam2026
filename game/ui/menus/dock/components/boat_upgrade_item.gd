@tool
class_name UIBoatUpgradeItem
extends MarginContainer

signal pressed

@export var equipment_stat_item_scene: PackedScene
@export var boat_icon: Texture2D:
	set(value):
		boat_icon = value
		if is_node_ready(): _update_icon()
@export var boat_name: String:
	set(value):
		boat_name = value
		if is_node_ready(): _update_name()
@export var boat_buy_price: int:
	set(value):
		boat_buy_price = value
		if is_node_ready(): _update_buy_price()
@export var boat_stats: Dictionary[Enums.BoatStat, int] = {}:
	set(value):
		boat_stats = value
		if is_node_ready(): _update_boat_stats()

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var buy_price: Label = %BuyPrice
@onready var stat_items: VBoxContainer = %StatItems
@onready var button: Button = %Button

var stat_items_cache: Dictionary[Enums.BoatStat, UIEquipmentStatItem] = {}
var is_initialized: bool = false

func _ready() -> void:
	button.pressed.connect(func(): pressed.emit())
	
	# Clear existing children to prevent duplicates if _ready re-runs
	for child in stat_items.get_children(): child.queue_free()
	stat_items_cache.clear()

	# Build Cache
	for stat in Enums.BoatStat.values():
		var stat_item = equipment_stat_item_scene.instantiate() as UIEquipmentStatItem
		if not stat_item: continue
		
		stat_item.name = str(stat)
		stat_items.add_child(stat_item)
		stat_items_cache[stat] = stat_item
	
	# Initial sync
	is_initialized = true
	_update_icon()
	_update_name()
	_update_buy_price()
	_update_boat_stats()

func _update_icon() -> void:
	if icon: icon.texture = boat_icon

func _update_name() -> void:
	if name_label: name_label.text = boat_name

func _update_buy_price() -> void:
	if buy_price: buy_price.text = str(boat_buy_price)

func _update_boat_stats() -> void:
	print("Updating stats for ", boat_name, ": ", boat_stats) # DEBUG
	# Only update if we have items AND we are fully initialized
	if stat_items_cache.is_empty() or not is_initialized: 
		return
		
	for stat in stat_items_cache:
		var item = stat_items_cache[stat]
		var stat_level: int = boat_stats.get(stat, 0)
		item.stat_name = str(Enums.BoatStat.keys()[stat]).capitalize()
		item.level = stat_level
