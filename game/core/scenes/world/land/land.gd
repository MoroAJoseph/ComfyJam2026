class_name WorldLand
extends Node3D

@onready var chunk_manager: VoxelEngineChunkManager = $ChunkManager

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.subscribe(WorldEvent.GenerateLand, _handle_world_generate_land)
	EventBus.subscribe(WorldEvent.PlayerSpawned, _handle_player_spawned)

func _exit_tree() -> void:
	EventBus.unsubscribe(WorldEvent.GenerateLand, _handle_world_generate_land)
	EventBus.unsubscribe(WorldEvent.PlayerSpawned, _handle_player_spawned)

# ===
# Private
# ===

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
