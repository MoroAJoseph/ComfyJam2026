class_name GameSaveController
extends Node

# TODO: Link with time context to auto-save

# ===
# Public
# ===

func save_data(data: SaveData) -> void:
	data.update()
	
	var error := ResourceSaver.save(data, Constants.USER_SAVE_PATH)
	if error != OK:
		push_error("MainSaveManager: Failed to save game to ", Constants.USER_SAVE_PATH, ". Error: ", error)
	else:
		print_debug("MainSaveManager: Game successfully saved to ", Constants.USER_SAVE_PATH)

func load_data(is_new_game: bool) -> SaveData:
	var path = Constants.NEW_GAME_SAVE_DATA_PATH if is_new_game else Constants.USER_SAVE_PATH
		
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
