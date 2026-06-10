class_name GameSceneController
extends Node

var current_scene: Node

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.subscribe(GameEvent.LoadTitle, _handle_game_load_title_scene)
	EventBus.subscribe(GameEvent.LoadWorld, _handle_game_load_world_scene)

func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvent.LoadTitle, _handle_game_load_title_scene)
	EventBus.unsubscribe(GameEvent.LoadWorld, _handle_game_load_world_scene)

# ===
# Event Handlers
# ===

func _handle_game_load_title_scene(_event: GameEvent.LoadTitle) -> void:
	var title = AssetService.get_title_scene()
	
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	current_scene = title
	add_child(current_scene)

func _handle_game_load_world_scene(_event: GameEvent.LoadWorld) -> void:
	var world = AssetService.get_world_scene()
	
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	current_scene = world
	add_child(current_scene)
