@tool
class_name UIDockMenuSelectedEquipmentSection
extends PanelContainer

@export var equipment_type: Enums.EquipmentType

# Header
@onready var equipment_name: Label = %EquipmentName
@onready var equipment_slogan: Label = %EquipmentSlogan

# Body
@onready var nav_left: Button = %NavLeft
@onready var nav_right: Button = %NavRight
@onready var stats_container: VBoxContainer = %StatsContainer

# Footer
@onready var buy_price: Label = %BuyPrice
@onready var buy_button: Button = %BuyButton

func _ready() -> void:
	nav_left.pressed.connect(func(): return)
	nav_right.pressed.connect(func(): return)
	buy_button.pressed.connect(func(): return)
