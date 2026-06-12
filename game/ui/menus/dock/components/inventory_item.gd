@tool
class_name UIDockInventoryItemSlot
extends PanelContainer

signal selected

@export var item_icon: Texture2D:
	set(value):
		item_icon = value
		if is_node_ready(): _update_icon()
@export var item_stack_quantity: int:
	set(value):
		item_stack_quantity = value
		if is_node_ready(): _update_stack_quantity()

@onready var icon: TextureRect = %Icon
@onready var stack_quantity: Label = %StackQuantity
@onready var button: Button = %Button

# ===
# Built-In
# ===

func _ready() -> void:
	button.pressed.connect(func(): selected.emit())
	_update_icon()
	_update_stack_quantity()

# ===
# Public
# ====

func set_data(data: BlockItemData) -> void:
	item_icon = data.texture
	item_stack_quantity = data.stack_count

# ===
# Private
# ===

func _update_icon() -> void:
	icon.texture = item_icon

func _update_stack_quantity() -> void:
	stack_quantity.text = str(item_stack_quantity)
