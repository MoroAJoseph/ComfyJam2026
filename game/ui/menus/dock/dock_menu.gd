extends Control

@onready var gold_label: Label = %GoldLabel
@onready var upgrade_boat_button: Button = %UpgradeBoat
@onready var boat_platform: Node3D = %BoatPlatform

var progression_context: ProgressionContext
var current_preview_boat: Node3D

var boat_scenes = {
	Enums.BoatType.ROW_SMALL: preload("res://features/boats/row_boat_small/row_boat_small.tscn"),
	Enums.BoatType.SHIP_SMALL: preload("res://features/boats/ship_small/ship_small.tscn"),
	Enums.BoatType.SHIP_MEDIUM_2: preload("res://features/boats/ship_medium_2/ship_medium_2.tscn")
}

func _ready() -> void:
	progression_context = Context.progression
	
	# Initial gold update
	_update_gold_label(progression_context.gold)
	_update_upgrade_ui(progression_context.equipped_boat_type)
	
	# Listen for gold updates
	progression_context.gold_updated.connect(_update_gold_label)
	progression_context.equipped_boat_type_updated.connect(_update_upgrade_ui)

func _process(delta: float) -> void:
	if boat_platform:
		boat_platform.rotate_y(delta * 0.5)

# ===
# Private
# ===

func _update_gold_label(value: int) -> void:
	gold_label.text = "Gold: %d" % value
	_update_upgrade_button_label(progression_context.equipped_boat_type)

func _update_upgrade_ui(current_type: Enums.BoatType) -> void:
	var next_type = _get_next_boat_type(current_type)
	_update_upgrade_button_label(current_type)
	_update_boat_preview(next_type)

func _get_next_boat_type(current_type: Enums.BoatType) -> Enums.BoatType:
	match current_type:
		Enums.BoatType.ROW_SMALL:
			return Enums.BoatType.SHIP_SMALL
		Enums.BoatType.SHIP_SMALL:
			return Enums.BoatType.SHIP_MEDIUM_2
		_:
			return current_type

func _update_boat_preview(type: Enums.BoatType) -> void:
	# Clear old preview
	if current_preview_boat:
		current_preview_boat.queue_free()
		current_preview_boat = null
	
	# Don't show preview if max level
	if progression_context.equipped_boat_type == Enums.BoatType.SHIP_MEDIUM_2:
		return

	if boat_scenes.has(type):
		var boat_instance = boat_scenes[type].instantiate()
		
		# Disable physics and scripts for the preview
		if boat_instance is RigidBody3D:
			boat_instance.freeze = true
		boat_instance.process_mode = PROCESS_MODE_DISABLED
		
		boat_platform.add_child(boat_instance)
		current_preview_boat = boat_instance
		# Center it a bit if needed, or adjust camera in tscn
		boat_instance.position = Vector3.ZERO

func _update_upgrade_button_label(current_type: Enums.BoatType) -> void:
	var next_type = _get_next_boat_type(current_type)
	
	if next_type == current_type:
		upgrade_boat_button.text = "Max Level Reached"
		upgrade_boat_button.disabled = true
		return

	var boat_data = Constants.LUT.get_boat_data(next_type)
	if boat_data:
		upgrade_boat_button.text = "Upgrade to %s (%d Gold)" % [boat_data.display_name, boat_data.price]
		upgrade_boat_button.disabled = progression_context.gold < boat_data.price
	else:
		upgrade_boat_button.text = "Error: Data Not Found"
		upgrade_boat_button.disabled = true

# ===
# Signals
# ===

func _on_close_pressed() -> void:
	EventBus.emit(UIEvent.DockMenu.new(Enums.DockMenuAction.CLOSE))

func _on_upgrade_boat_pressed() -> void:
	EventBus.emit(UIEvent.DockMenu.new(Enums.DockMenuAction.PURCHASE))
	
