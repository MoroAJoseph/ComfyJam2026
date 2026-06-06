class_name Dock
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var prompt: Label3D = $Prompt

var _player_in_range := false

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt.hide()

func _input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("player_interact"):
		_interact()

func _on_body_entered(body: Node3D) -> void:
	if body is Boat:
		_player_in_range = true
		prompt.show()
		EventBus.emit(DockEvent.Entered.new())

func _on_body_exited(body: Node3D) -> void:
	if body is Boat:
		_player_in_range = false
		prompt.hide()
		EventBus.emit(DockEvent.Exited.new())

func _interact() -> void:
	# 1. Trigger Checkpoint (Save)
	# We can emit an event that the GameSaveController listens to, 
	# or just call it if we can find it. 
	# For now, let's assume there's a Global Save event.
	# EventBus.emit(SaveEvent.TriggerSave.new())
	
	# 2. Open Upgrade Menu
	# EventBus.emit(UIEvent.OpenMenu.new(UIContext.MenuOption.UPGRADES))
	
	print_debug("Dock: Interacted! Saving and opening upgrades...")
	EventBus.emit(DockEvent.Interact.new())
