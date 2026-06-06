class_name MainSceneController
extends Node

@export var bootsplash_scene: PackedScene
@export var game_scene: PackedScene

var current_scene: Node

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.subscribe(MainEvent.LoadBootsplash, _handle_main_load_bootsplash)
	EventBus.subscribe(MainEvent.LoadGame, _handle_main_load_game)

func _exit_tree() -> void:
	EventBus.unsubscribe(MainEvent.LoadBootsplash, _handle_main_load_bootsplash)
	EventBus.unsubscribe(MainEvent.LoadGame, _handle_main_load_game)

# ===
# Private
# ===


# ===
# Event Handlers
# ===

func _handle_main_load_bootsplash(_event: MainEvent.LoadBootsplash) -> void:
	var bootsplash = bootsplash_scene.instantiate()
	
	if current_scene:
		current_scene.queue_free()
		
	current_scene = bootsplash
	add_child(current_scene)

func _handle_main_load_game(_event: MainEvent.LoadGame) -> void:
	var game = game_scene.instantiate()
	
	if current_scene:
		current_scene.queue_free()
	
	current_scene = game
	add_child(current_scene)
