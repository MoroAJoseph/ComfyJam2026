class_name GameSaveController
extends Node

@onready var _timer: Timer = $AutoSaveTimer

# ===
# Built-In
# ===

func _ready() -> void:
	if _timer:
		_timer.timeout.connect(_on_auto_save_timeout)

# ===
# Public
# ===
...
# ===
# Signals
# ===

func _on_auto_save_timeout() -> void:
	if Context.session and Context.session.is_in_world: # Assuming this flag exists or we can check state
		var data = SaveData.new()
		save_data(data)

func save_data(data: SaveData) -> void:
	data.update()
	
	var error := ResourceSaver.save(data, Constants.Paths.USER_SAVE)
	if error != OK:
		push_error("MainSaveManager: Failed to save game to ", Constants.Paths.USER_SAVE, ". Error: ", error)
	else:
		print_debug("MainSaveManager: Game successfully saved to ", Constants.Paths.USER_SAVE)

func load_data(is_new_game: bool) -> SaveData:
	var path = Constants.Paths.NEW_GAME_SAVE_DATA if is_new_game else Constants.Paths.USER_SAVE
		
	# Check if file exists
	if not FileAccess.file_exists(path):
		push_warning("MainSaveManager: File at ", path, " not found. Falling back to default SaveData.")
		return SaveData.new()
	
	# Load the resource
	var data = load(path)
	
	# Validate the loaded resource type
	if not (data is SaveData):
		push_error("MainSaveManager: File at ", path, " is not of type SaveData. Check your file path and resource type.")
		return SaveData.new()
	
	print_debug("MainSaveManager: Successfully loaded data from ", path)
	return data
