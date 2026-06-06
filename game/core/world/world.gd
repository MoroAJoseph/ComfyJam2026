class_name World
extends Node3D


var context: WorldContext

# ===
# Built-In
# ===

func _ready() -> void:
	context = Context.world
	
	EventBus.emit(
		GameEvent.WorldLoaded.new()
	)
	
	# CRITICAL TEMPORARY
	Context.progression.equipped_boat_type = BoatData.Type.ROW_SMALL
	
	EventBus.emit(
		WorldEvent.SpawnPlayer.new(
			Vector3(0, 5, 0),
			Vector3(0, 0, 0)
		)
	)
