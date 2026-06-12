@tool
class_name UIToolUpgrades
extends UIEquipmentUpgradeSection

signal upgrade_item_selected(tool_type: Enums.ToolType)

@export var tool_ownership_status: Dictionary[Enums.ToolType, bool] = {}:
	set(value):
		tool_ownership_status = value
		if is_node_ready():
			_update_owned_status_ui(tool_ownership_status)
			_update_tool_upgrade_items()

var tool_data_cache: Dictionary[Enums.ToolType, ToolData] = {}

func _ready() -> void:
	super._ready()
	_initialize_ui.call_deferred()

func _initialize_ui() -> void:
	for type in Enums.ToolType.values():
		var tool_data = AssetService.get_tool_data(type)
		if tool_data: tool_data_cache[type] = tool_data
	
	_update_items_container()
	if tool_ownership_status.is_empty():
		tool_ownership_status = _prefill_tool_ownership_status()
	
	_update_owned_status_ui(tool_ownership_status)
	_update_tool_upgrade_items()

func _update_tool_upgrade_items() -> void:
	pass

func _update_items_container() -> void:
	if not is_node_ready() or not items_container: return
	
	for child in items_container.get_children(): 
		child.queue_free()
	
	if not equipment_upgrade_item_scene:
		return

	upgrade_button_group = ButtonGroup.new()
	
	for tool_type in tool_data_cache:
		var data: ToolData = tool_data_cache[tool_type]
		var item: UIEquipmentUpgradeItem = equipment_upgrade_item_scene.instantiate()
		
		items_container.add_child(item)
		
		# In @tool mode, we must wait for the child to be ready so %Button is linked
		# If the item isn't ready yet, we use call_deferred to setup the UI properties
		item.call_deferred("_setup_upgrade_item", data, tool_type, upgrade_button_group, self)

func _update_boat_upgrade_items() -> void:
	for tool_type in upgrade_items:
		upgrade_items[tool_type].visible = tool_ownership_status.get(tool_type, false)

func _prefill_tool_ownership_status() -> Dictionary[Enums.ToolType, bool]:
	var value: Dictionary[Enums.ToolType, bool] = {}
	for type in Enums.ToolType.values():
		value[type] = false
	return value

func _on_upgrade_item_pressed(tool_type: int) -> void:
	upgrade_item_selected.emit(tool_type as Enums.ToolType)
