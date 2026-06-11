@tool
class_name UIDockMenuSpecialItem
extends PanelContainer

signal buy_pressed

@export var item_icon: Texture2D:
	set(value):
		item_icon = value
		if is_node_ready():
			_update_icon()
@export var item_name: String:
	set(value):
		item_name = value
		if is_node_ready():
			_update_name()
@export var item_description: String:
	set(value):
		item_description = value
		if is_node_ready():
			_update_description()
@export var item_buy_price: int:
	set(value):
		item_buy_price = value
		if is_node_ready():
			_update_buy_price()
@export var can_afford: bool = true:
	set(value):
		can_afford = value
		if is_node_ready():
			_update_buy_button()

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var description: RichTextLabel = %Description
@onready var coin_icon: TextureRect = %CoinIcon
@onready var buy_price: Label = %BuyPrice
@onready var buy_button: Button = %BuyButton

func _ready() -> void:
	buy_button.pressed.connect(func(): buy_pressed.emit())
	_update_icon()
	_update_name()
	_update_description()
	_update_buy_price()

# ===
# Private
# ===

func _update_icon() -> void:
	icon.texture = item_icon

func _update_name() -> void:
	name_label.text = item_name

func _update_description() -> void:
	description.text = item_description

func _update_buy_price() -> void:
	buy_price.text = str(item_buy_price)

func _update_buy_button() -> void:
	buy_button.disabled = not can_afford
