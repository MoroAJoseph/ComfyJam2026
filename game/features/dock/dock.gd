class_name Dock
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea

# ===
# Built-In
# ===

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

# ===
# Signals
# ===

func _on_body_entered(body: Node3D) -> void:
	if body is Boat:
		EventBus.emit(WorldEvent.DockEntered.new())

func _on_body_exited(body: Node3D) -> void:
	if body is Boat:
		EventBus.emit(WorldEvent.DockExited.new())
