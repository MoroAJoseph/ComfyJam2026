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
	_update_upgrade_button_label()
	
	# Listen for gold updates
	Context.progression.gold_updated.connect(_update_gold_label)

func _on_close_pressed() -> void:
	EventBus.emit(UIEvent.ToggleMenu.new(UIContext.MenuOption.UPGRADES, false))

func _on_upgrade_boat_pressed() -> void:
	var progression = Context.progression
	
	match progression.equipped_boat_type:
		BoatData.Type.ROW_SMALL:
			if progression.gold >= 50:
				progression.gold -= 50
				progression.equipped_boat_type = BoatData.Type.SHIP_SMALL
				print_debug("Upgrade: Boat upgraded to SHIP_SMALL!")
				_update_upgrade_button_label()
			else:
				print_debug("Upgrade: Not enough gold for SHIP_SMALL!")
		
		BoatData.Type.SHIP_SMALL:
			if progression.gold >= 150:
				progression.gold -= 150
				progression.equipped_boat_type = BoatData.Type.SHIP_MEDIUM_2
				print_debug("Upgrade: Boat upgraded to SHIP_MEDIUM_2!")
				_update_upgrade_button_label()
			else:
				print_debug("Upgrade: Not enough gold for SHIP_MEDIUM_2!")
		
		BoatData.Type.SHIP_MEDIUM_2:
			print_debug("Upgrade: Boat is already at max level!")

func _update_gold_label(value: int) -> void:
	gold_label.text = "Gold: %d" % value

func _update_upgrade_button_label() -> void:
	var progression = Context.progression
	match progression.equipped_boat_type:
		BoatData.Type.ROW_SMALL:
			boat_upgrade_button.text = "Upgrade to Small Ship (50 Gold)"
			boat_upgrade_button.disabled = false
		BoatData.Type.SHIP_SMALL:
			boat_upgrade_button.text = "Upgrade to Medium Pirate Ship (150 Gold)"
			boat_upgrade_button.disabled = false
		BoatData.Type.SHIP_MEDIUM_2:
			boat_upgrade_button.text = "Max Level Reached"
			boat_upgrade_button.disabled = true
