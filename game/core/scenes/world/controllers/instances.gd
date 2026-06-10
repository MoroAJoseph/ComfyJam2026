class_name WorldInstancesController
extends Node

@onready var sailors: Node3D = %Sailors
@onready var block_items: Node3D = $BlockItems

# ===
# Built-In
# ===

func _ready() -> void:
	_subscribe()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Private
# ====

func _subscribe() -> void:
	EventBus.subscribe(WorldEvent.SpawnPlayer, _handle_world_spawn_player)
	EventBus.subscribe(WorldEvent.SpawnBlockItem, _handle_world_spawn_block_item)

func _unsubscribe() -> void:
	EventBus.unsubscribe(WorldEvent.SpawnPlayer, _handle_world_spawn_player)
	EventBus.unsubscribe(WorldEvent.SpawnBlockItem, _handle_world_spawn_block_item)

# ===
# Public
# ===

func _spawn_player(world_location: Vector3, rotation: Vector3) -> void:
	var player: Player = AssetService.get_player_scene()
	
	sailors.add_child(player)
	
	player.global_position = world_location
	player.global_rotation = rotation
	
	EventBus.emit(
		WorldEvent.PlayerSpawned.new(
			player
		)
	)

func _spawn_block_item(item_data: BlockItemData, world_location: Vector3) -> void:
	var block_item: BlockItem = AssetService.get_block_item_scene()
	
	block_item.data = item_data
	block_items.add_child(block_item)
	
	block_item.global_position = world_location

# ===
# Event Handlers
# ===

func _handle_world_spawn_player(event: WorldEvent.SpawnPlayer) -> void:
	_spawn_player(
		event.world_location, 
		event.rotation
	)

func _handle_world_spawn_block_item(event: WorldEvent.SpawnBlockItem) -> void:
	_spawn_block_item(
		event.item_data,
		event.world_location
	)
