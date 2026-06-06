class_name UpgradeMenu
extends Control

@onready var close_button: Button = %Close
@onready var boat_upgrade_button: Button = %UpgradeBoat
@onready var gold_label: Label = %GoldLabel

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	boat_upgrade_button.pressed.connect(_on_upgrade_boat_pressed)
	
	# Initial gold update
	_update_gold_label(Context.progression.gold)
	
	# Listen for gold updates
	Context.progression.gold_updated.connect(_update_gold_label)

func _on_close_pressed() -> void:
	EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.UPGRADES, false))

func _on_upgrade_boat_pressed() -> void:
	var progression = Context.progression
	if progression.gold >= 50:
		progression.gold -= 50
		progression.equipped_boat_type = BoatData.Type.SHIP_SMALL
		print_debug("Upgrade: Boat upgraded to SHIP_SMALL!")
	else:
		print_debug("Upgrade: Not enough gold!")

func _update_gold_label(value: int) -> void:
	gold_label.text = "Gold: %d" % value
