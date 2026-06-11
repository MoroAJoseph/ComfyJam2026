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
	
	#EventBus.emit(
		#WorldEvent.SpawnPlayer.new(
			#Vector3(0, 30, 0),
			#Vector3(0, 0, 0)
		#)
	#)
	await get_tree().process_frame
	EventBus.emit(
		WorldEvent.GenerateLand.new()
	)

func _exit_tree() -> void:
	_unsubscribe()
	
# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(WorldEvent.LandGenerated, _handle_world_land_generated)
	EventBus.subscribe(WorldEvent.BlockDestroyed, _handle_world_block_destroyed)

func _unsubscribe() -> void:
	EventBus.unsubscribe(WorldEvent.LandGenerated, _handle_world_land_generated)
	EventBus.unsubscribe(WorldEvent.BlockDestroyed, _handle_world_block_destroyed)

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

func _handle_world_block_destroyed(event: WorldEvent.BlockDestroyed) -> void:
	var block_item_data: BlockItemData = BlockItemData.new(
		event.type,
		1 # TODO: Some tools may increase this quantity
	)
	
	EventBus.emit(
		WorldEvent.SpawnBlockItem.new(
			block_item_data,
			event.world_location
		)
	)
