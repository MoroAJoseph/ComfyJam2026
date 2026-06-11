@tool
class_name SpecialItemData
extends Resource

@export var type: Enums.SpecialItemType
@export var display_name: String
@export var icon: Texture2D
@export var description: String
@export var buy_price: int
@export var sell_price: int
@export var can_sell: bool = true
