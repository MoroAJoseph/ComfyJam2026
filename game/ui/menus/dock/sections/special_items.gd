@tool
class_name UIDockMenuSpecialItemsSection
extends PanelContainer

@export var special_items: Array[Enums.SpecialItemType] = []:
	set(value):
		special_items = value
		if is_node_ready(): _update_items()
@export var affordability_status: Dictionary[Enums.SpecialItemType, bool] = {}:
	set(value):
		affordability_status = value
		if is_node_ready(): _update_items()

@onready var items_container: HBoxContainer = %ItemsContainer
var special_item_views: Array[UIDockMenuSpecialItem] = []

func _ready() -> void:
	for child in items_container.get_children():
		if child is UIDockMenuSpecialItem:
			special_item_views.append(child)
	_update_items()

func _update_items() -> void:
	if not is_node_ready(): return
	
	for i in range(special_item_views.size()):
		var view: UIDockMenuSpecialItem = special_item_views[i]
		
		if i < special_items.size():
			var type: Enums.SpecialItemType = special_items[i]
			var data: SpecialItemData = AssetService.get_special_item_data(type)
			
			if data:
				view.visible = true
				view.item_icon = data.icon
				view.item_name = data.display_name
				view.item_description = data.description
				view.item_buy_price = data.buy_price
				view.can_afford = affordability_status.get(type, false)
			else:
				view.visible = false
		else:
			view.visible = false
