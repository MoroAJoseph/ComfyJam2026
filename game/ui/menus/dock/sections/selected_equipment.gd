@tool
class_name UIDockMenuSelectedEquipmentSection
extends PanelContainer

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
