class_name World
extends Node3D


var context: WorldContext

# ===
# Built-In
# ===

func _ready() -> void:
	context = Session.world_context
	_subscribe()
	
	EventBus.emit(
		GameEvent.WorldLoaded.new()
	)
	
	# CRITICAL TEMPORARY
	Session.player_context.equipped_boat = Enums.BoatType.ROW_SMALL
	
	EventBus.emit(
		WorldEvent.SpawnPlayer.new(
			Vector3(0, 30, 0),
			Vector3(0, 0, 0)
		)
	)
	
	#EventBus.emit(
		#WorldEvent.GenerateLand.new()
	#)

func _exit_tree() -> void:
	_unsubscribe()
	
# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(WorldEvent.LandGenerated, _handle_world_land_generated)

func _unsubscribe() -> void:
	EventBus.unsubscribe(WorldEvent.LandGenerated, _handle_world_land_generated)
	
# ===
# Event Handlers
# ===

func _handle_world_land_generated(_event: WorldEvent.LandGenerated) -> void:
	await get_tree().create_timer(3.0).timeout
	EventBus.emit(
		WorldEvent.SpawnPlayer.new(
			Vector3(0, 30, 0),
			Vector3(0, 0, 0)
		)
	)

func _handle_player_spawned() -> void:
	# world ready, hide loading screen
	pass
