extends Control

@onready var gold_label: Label = %GoldLabel
@onready var upgrade_boat_button: Button = %UpgradeBoat

var progression_context: ProgressionContext

func _ready() -> void:
	progression_context = Context.progression
	
	# Initial gold update
	_update_gold_label(progression_context.gold)
	_update_upgrade_button_label(progression_context.equipped_boat_type)
	
	# Listen for gold updates
	progression_context.gold_updated.connect(_update_gold_label)
	progression_context.equipped_boat_type_updated.connect(_update_upgrade_button_label)

# ===
# Private
# ===

func _update_gold_label(value: int) -> void:
	gold_label.text = "Gold: %d" % value

func _update_upgrade_button_label(value: Enums.BoatType) -> void:
	match value:
		Enums.BoatType.ROW_SMALL:
			upgrade_boat_button.text = "Upgrade to Small Ship (50 Gold)"
			upgrade_boat_button.disabled = false
		Enums.BoatType.SHIP_SMALL:
			upgrade_boat_button.text = "Upgrade to Medium Pirate Ship (150 Gold)"
			upgrade_boat_button.disabled = false
		Enums.BoatType.SHIP_MEDIUM_2:
			upgrade_boat_button.text = "Max Level Reached"
			upgrade_boat_button.disabled = true

# ===
# Signals
# ===

func _on_close_pressed() -> void:
	EventBus.emit(UIEvent.DockMenu.new(Enums.DockMenuAction.CLOSE))

func _on_upgrade_boat_pressed() -> void:
	EventBus.emit(UIEvent.DockMenu.new(Enums.DockMenuAction.PURCHASE))
	
