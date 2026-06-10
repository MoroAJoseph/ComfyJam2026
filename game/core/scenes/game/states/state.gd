class_name GameState
extends State

enum StateName { LOAD, TITLE, WORLD }

var _owner: Game


class GameLoadStateData:

	var target_state: GameState.StateName
	var is_new_game: bool
	var save_game_file_path: String

	func _init(
		p_target_state: GameState.StateName, 
		p_is_new_game: bool,
		p_save_game_file_path: String
	):
		target_state = p_target_state
		is_new_game = p_is_new_game
		save_game_file_path = p_save_game_file_path


# ===
# Built-In
# ===

func _ready() -> void:
	await owner.ready
	_owner = owner as Game

# ===
# Public
# ===

func get_state_name(state: StateName) -> String:
	return StateName.keys()[state].capitalize()

# ===
# Private
# ===

func _transition_to(state: StateName, data: Object) -> void:
	finished.emit(get_state_name(state), data)
