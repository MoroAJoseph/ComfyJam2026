class_name WorldInstancesController
extends Node

@onready var sailors: Node3D = %Sailors
@onready var docks: Node3D = %Docks
@onready var treasure: Node3D = $Treasure
@onready var land : WorldLand = $Land

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

func _unsubscribe() -> void:
	EventBus.unsubscribe(WorldEvent.SpawnPlayer, _handle_world_spawn_player)

# ===
# Public
# ===

func spawn_player(position: Vector3, rotation: Vector3) -> void:
	var player_scene: PackedScene = load(Constants.Paths.PLAYER_SCENE)
	var player: Player = player_scene.instantiate()
	
	sailors.add_child(player)
	
	player.global_position = position
	player.global_rotation = rotation
	
	EventBus.emit(
		WorldEvent.PlayerSpawned.new(
			player
		)
	)

# ===
# Event Handlers
# ===

func _handle_world_spawn_player(event: WorldEvent.SpawnPlayer) -> void:
	spawn_player(
		event.position, 
		event.rotation
	)
