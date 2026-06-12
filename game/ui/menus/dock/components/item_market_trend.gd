@tool
class_name UIDockItemMarketTrend
extends MarginContainer

@export var hot_trend_arrow_icon: Texture2D
@export var cold_trend_arrow_icon: Texture2D
@export var hot_difference_color: Color
@export var cold_difference_color: Color
@export var block_type: Enums.BlockType:
	set(value):
		block_type = value
		if is_node_ready():
			_update_ui()
@export var trend: Enums.ItemMarketTrend

@onready var hot_cold: Label = %HotCold
@onready var arrow_icon: TextureRect = %ArrowIcon
@onready var difference: Label = %Difference
@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name: Label = %ItemName
@onready var new_sell_price: Label = %NewSellPrice
@onready var base_sell_price: Label = %BaseSellPrice


func _update_ui() -> void:
	if block_type == Enums.BlockType.NONE: 
		print_debug("None")
		return
	
	var block_data: BlockData = AssetService.get_block_data(block_type)
	print_debug(block_data)
	item_icon.texture = block_data.icon
	item_name.text = block_data.display_name
	base_sell_price.text = str(block_data.value)
	
	match trend:
		Enums.ItemMarketTrend.HOT:
			hot_cold.text = "Hot Item"
			arrow_icon.texture = hot_trend_arrow_icon
			difference.text = "+ 50%"
			difference.add_theme_color_override("font_color", hot_difference_color)
			new_sell_price.text = str(block_data.value * 1.5)
		Enums.ItemMarketTrend.COLD:
			hot_cold.text = "Cold Item"
			arrow_icon.texture = cold_trend_arrow_icon
			difference.text = "- 50%"
			difference.add_theme_color_override("font_color", cold_difference_color)
			new_sell_price.text = str(block_data.value * 0.5)
