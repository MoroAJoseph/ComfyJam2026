@tool
class_name UIDockMenuSellCargoSection
extends PanelContainer

signal sell_pressed(
	block_type: Enums.BlockType, 
	quantity: int
)

@export var inventory_item_slot_scene: PackedScene
@export var selected_item: BlockItemData
@export var selected_quantity: int = 0
@export var total_item_quantity: int = 0

# Inventory
@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var weight_bar: ProgressBar = %WeightBar
@onready var capacity_bar: ProgressBar = %CapacityBar

# Controls
@onready var item_name: Label = %ItemName
@onready var total_item_quantity_label: Label = %TotalItemQuantity
@onready var selected_quantity_label: Label = %SelectedQuantity
@onready var decrease_button: Button = %Decrease
@onready var increase_button: Button = %Increase
@onready var max_button: Button = %Max
@onready var sell_button: Button = %Sell
@onready var coin_icon: TextureRect = %CoinIcon
@onready var total_sell_value: Label = %TotalSellValue

# ===
# Built-In
# ===

func _ready() -> void:
	decrease_button.pressed.connect(func(): _change_selected_quantity(-1))
	increase_button.pressed.connect(func(): _change_selected_quantity(1))
	max_button.pressed.connect(func(): _change_selected_quantity(total_item_quantity - selected_quantity))
	sell_button.pressed.connect(_on_sell_pressed)

# ===
# Private
# ===

func _change_selected_quantity(delta: int) -> void:
	selected_quantity = clampi(
		selected_quantity + delta, 
		0, 
		total_item_quantity
	)
	_update_ui()

func _update_ui() -> void:
	if not selected_item: return
	
	var sell_value_per_unit: int = selected_item.block_data.value
	var total_value: int = sell_value_per_unit * selected_quantity
	
	total_sell_value.text = str(total_value)
	selected_quantity_label.text = str(selected_quantity)
	item_name.text = selected_item.block_data.display_name

# ===
# Event Handlers
# ===

func _handle_world_item_sold() -> void:
	pass

# ===
# Signals
# ===

func _on_slot_selected(item_data: BlockItemData) -> void:
	selected_item = item_data
	selected_quantity = 0
	_update_ui()

func _on_sell_pressed() -> void:
	sell_pressed.emit(
		selected_item.type, 
		selected_quantity
	)
