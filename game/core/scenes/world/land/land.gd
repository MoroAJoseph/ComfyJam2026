class_name WorldLand
extends Node3D

@onready var chunk_manager: VoxelEngineChunkManager = $ChunkManager


# ===
# Built-In
# ===

func _ready() -> void:
	Session.world_context.noise_seed = chunk_manager.noise_seed
	Session.world_context.chunk_size = chunk_manager.chunk_size
	Session.world_context.generation_height = chunk_manager.generation_height
	EventBus.subscribe(WorldEvent.GenerateLand, _handle_world_generate_land)
	EventBus.subscribe(WorldEvent.PlayerSpawned, _handle_player_spawned)

func _exit_tree() -> void:
	EventBus.unsubscribe(WorldEvent.GenerateLand, _handle_world_generate_land)
	EventBus.unsubscribe(WorldEvent.PlayerSpawned, _handle_player_spawned)

# ===
# Private
# ===

func generate() -> void:
	chunk_manager.generate(Session.world_context.noise_seed)
	Session.world_context.chunks_data = chunk_manager.chunks_data
	Session.world_context.land_generated = true
	
	EventBus.emit(
		WorldEvent.LandGenerated.new()
	)

# ===
# Event Handlers
# ===

func _handle_world_generate_land(_event: WorldEvent.GenerateLand) -> void:
	generate()

func _handle_player_spawned(_event: WorldEvent.PlayerSpawned) -> void:
	chunk_manager.context_target = Session.player_context.boat_instance
