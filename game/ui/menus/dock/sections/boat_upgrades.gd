@tool
class_name UIBoatUpgrades
extends UIEquipmentUpgradeSection

signal upgrade_item_selected(boat_type: Enums.BoatType)

@export var boat_ownership_status: Dictionary[Enums.BoatType, bool] = {}:
	set(value):
		boat_ownership_status = value
		if is_node_ready():
			_update_owned_status_ui(boat_ownership_status)
			_update_boat_upgrade_items()

# Keep specialized cache
var boat_data_cache: Dictionary[Enums.BoatType, BoatData] = {}

func _ready() -> void:
	super._ready()
	_initialize_ui.call_deferred()
	
func _initialize_ui() -> void:
	for type in Enums.BoatType.values():
		var boat_data = AssetService.get_boat_data(type)
		if boat_data: boat_data_cache[type] = boat_data
	
	_update_items_container()
	if boat_ownership_status.is_empty():
		boat_ownership_status = _prefill_boat_ownership_status()
	
	_update_owned_status_ui(boat_ownership_status)
	_update_boat_upgrade_items()

func _update_items_container() -> void:
	if not is_node_ready() or not items_container: return
	
	for child in items_container.get_children(): 
		child.queue_free()
	
	if not equipment_upgrade_item_scene:
		return

	upgrade_button_group = ButtonGroup.new()
	
	for boat_type in boat_data_cache:
		var data = boat_data_cache[boat_type]
		var item: UIEquipmentUpgradeItem = equipment_upgrade_item_scene.instantiate()
		
		items_container.add_child(item)
		
		# In @tool mode, we must wait for the child to be ready so %Button is linked
		# If the item isn't ready yet, we use call_deferred to setup the UI properties
		item.call_deferred("_setup_upgrade_item", data, boat_type, upgrade_button_group, self)

func _update_boat_upgrade_items() -> void:
	for boat_type in upgrade_items:
		upgrade_items[boat_type].visible = boat_ownership_status.get(boat_type, false)

func _prefill_boat_ownership_status() -> Dictionary[Enums.BoatType, bool]:
	var value: Dictionary[Enums.BoatType, bool] = {}
	for type in Enums.BoatType.values():
		value[type] = false
	return value

func _on_upgrade_item_pressed(boat_type: int) -> void:
	upgrade_item_selected.emit(boat_type as Enums.BoatType)
