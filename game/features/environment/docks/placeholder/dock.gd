class_name Dock
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea

# ===
# Built-In
# ===

# ===
# Private
# ===

# ===
# Signals
# ===

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body is Boat:
		EventBus.emit(WorldEvent.DockEntered.new())

func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body is Boat:
		EventBus.emit(WorldEvent.DockExited.new())
