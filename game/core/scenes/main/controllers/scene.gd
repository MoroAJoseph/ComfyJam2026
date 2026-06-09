class_name MainSceneController
extends Node

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
	var bootsplash = AssetProvider.get_bootsplash_scene()
	
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	current_scene = bootsplash
	add_child(current_scene)

func _handle_main_load_game(_event: MainEvent.LoadGame) -> void:
	var game = AssetProvider.get_game_scene()
	
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	current_scene = game
	add_child(current_scene)
