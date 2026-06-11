@tool
class_name UIBoatUpgrades
extends PanelContainer

signal upgrade_item_selected(boat_type: Enums.BoatType)

@export var boat_upgrade_item_scene: PackedScene
@export var boat_ownership_status: Dictionary[Enums.BoatType, bool] = {}:
	set(value):
		boat_ownership_status = value
		if is_node_ready():
			_update_owned_count()
			_update_boat_upgrade_items()

@onready var boat_upgrades_icon: TextureRect = %BoatUpgradesIcon
@onready var current_owned_count: Label = %CurrentOwnedCount
@onready var total_ownable_count: Label = %TotalOwnableCount
@onready var items_container: VBoxContainer = %ItemsContainer

var upgrade_items: Dictionary[Enums.BoatType, UIBoatUpgradeItem] = {}
var boat_data_cache: Dictionary[Enums.BoatType, BoatData] = {}
var upgrade_button_group: ButtonGroup

func _ready() -> void:
	
	# Build Data Cache
	for type in Enums.BoatType.values():
		var boat_data = AssetService.get_boat_data(type)
		if boat_data: boat_data_cache.set(type, boat_data)
	
	# Build UI items (populates upgrade_items dict)
	_update_items_container()
	
	# Ensure ownership status is initialized
	if boat_ownership_status.is_empty():
		boat_ownership_status = _prefill_boat_ownership_status()
	
	# Final sync
	_update_owned_count()
	_update_boat_upgrade_items()

# ===
# Public
# ===

func set_boat_owned(type: Enums.BoatType, is_owned: bool) -> void:
	# Update the value
	boat_ownership_status[type] = is_owned
	
	# Manually trigger the refresh logic
	if is_node_ready():
		_update_owned_count()
		_update_boat_upgrade_items()

# ===
# Private
# ===

func _prefill_boat_ownership_status() -> Dictionary[Enums.BoatType, bool]:
	var value: Dictionary[Enums.BoatType, bool] = {}
	for type in Enums.BoatType.values():
		value.set(type, false)
	return value

func _update_items_container() -> void:
	for child in items_container.get_children(): child.queue_free()
	upgrade_button_group = ButtonGroup.new()
	
	for boat_type in boat_data_cache.keys():
		var upgrade_item: UIBoatUpgradeItem = boat_upgrade_item_scene.instantiate()
		upgrade_item.pressed.connect(_on_upgrade_item_pressed.bind(boat_type))
		items_container.add_child(upgrade_item)
		upgrade_item.button.button_group = upgrade_button_group
		upgrade_items[boat_type] = upgrade_item
		
		# Pull data
		var data = boat_data_cache.get(boat_type)
		upgrade_item.boat_name = data.display_name
		upgrade_item.boat_buy_price = data.buy_price
		
		var stats_dict: Dictionary[Enums.BoatStat, int] = {}
		for boat_stat in Enums.BoatStat.values():
			stats_dict[boat_stat] = data.get_stat(boat_stat)
		
		# Single assignment triggers the child's setter once
		upgrade_item.boat_stats = stats_dict

func _update_owned_count() -> void:
	total_ownable_count.text = str(boat_ownership_status.size())
	
	var count: int = boat_ownership_status.values().filter(
		func(value): return value
	).size()
	
	current_owned_count.text = str(count)

func _update_boat_upgrade_items() -> void:
	# This now correctly syncs visibility based on the dictionary state
	for boat_type in upgrade_items:
		var item: UIBoatUpgradeItem = upgrade_items.get(boat_type)
		var is_owned: bool = boat_ownership_status.get(boat_type, false)
		item.visible = is_owned

# ===
# Signals
# ===

func _on_upgrade_item_pressed(boat_type: Enums.BoatType) -> void:
	upgrade_item_selected.emit(boat_type)
	print_debug("Selected boat: ", boat_type)
