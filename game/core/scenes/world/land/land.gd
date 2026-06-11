class_name WorldLand
extends Node3D

@onready var chunk_manager: VoxelEngineChunkManager = $ChunkManager

# ===
# Built-In
# ===

func _ready() -> void:
	chunk_manager.block_removed.connect(_on_block_removed)
	_subscribe()

func _exit_tree() -> void:
	_unsubscribe()

# ===
# Private
# ===

func _subscribe() -> void:
	EventBus.subscribe(WorldEvent.GenerateLand, _handle_world_generate_land)
	EventBus.subscribe(WorldEvent.PlayerSpawned, _handle_player_spawned)

func _unsubscribe() -> void:
	EventBus.unsubscribe(WorldEvent.GenerateLand, _handle_world_generate_land)
	EventBus.unsubscribe(WorldEvent.PlayerSpawned, _handle_player_spawned)

func generate() -> void:
	chunk_manager.generate_data()
	EventBus.emit(
		WorldEvent.LandGenerated.new()
	)

# ===
# Event Handlers
# ===

func _handle_world_generate_land(_event: WorldEvent.GenerateLand) -> void:
	generate()

func _handle_player_spawned(_event: WorldEvent.PlayerSpawned) -> void:
	chunk_manager.start_tracking(Session.player_context.boat_instance)

# ===
# Signals
# ===

func _on_block_removed(block_type: Enums.BlockType, global_pos: Vector3i) -> void:
	# TODO: Set this block position and type as NEGATIVE with the world_provider
	EventBus.emit(
		WorldEvent.BlockDestroyed.new(
			block_type, 
			global_pos
		)
	)
