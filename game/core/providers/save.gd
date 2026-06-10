class_name SaveProvider
extends ContextProvider

var settings_context: SettingsContext
var progression_context: ProgressionContext
var player_context: PlayerContext
var world_context: WorldContext

# ===
# Built-In
# ===

func _init(
	p_settings: SettingsContext,
	p_progression: ProgressionContext, 
	p_player: PlayerContext, 
	p_world: WorldContext
) -> void:
	settings_context = p_settings
	progression_context = p_progression
	player_context = p_player
	world_context = p_world

# ===
# Public
# ===

# --- Game ---
func save_game(data: GameSaveData, is_autosave: bool) -> void:
	# Update
	_game_to_data(data)
	
	# Write
	var dir: String = Constants.Paths.Data.USER_GAME_AUTOSAVES_DIR if is_autosave else Constants.Paths.Data.USER_GAME_SAVES_DIR
	var filename: String = _current_timestamp() + ".tres"
	var path: String = dir + filename
	var error := ResourceSaver.save(data, path)
	
	# Notify
	if error != OK:
		_error_failed_to_save(error)

func load_new_game() -> GameSaveData:
	return load_game(Constants.Paths.Data.NEW_GAME_SAVE)

func load_game(path: String) -> GameSaveData:
	# Read
	var data := AssetLoader.load_resource(
		path, 
		GameSaveData
	) as GameSaveData
	
	# Contingency
	var resave: bool = false
	if not data:
		_warn_no_save_at_path(path)
		resave = true
		data = AssetLoader.load_resource(
			Constants.Paths.Data.NEW_GAME_SAVE, 
			GameSaveData
		) as GameSaveData
		
		if not data: 
			_error_failed_to_load(path)
			return null
	
	# Update
	_data_to_game(data)
	
	# Resave
	if resave:
		save_game(data, false)
	
	return data
	
# --- Settings ---
func save_settings(data: SettingsSaveData) -> void:
	# Update
	_settings_to_data(data)

	# Write
	var error := ResourceSaver.save(
		data,
		Constants.Paths.Data.USER_SETTINGS_SAVE
	)
	
	# Notify
	if error != OK:
		_error_failed_to_save(error)


func load_settings(path: String) -> SettingsSaveData:
	# Read
	var data := AssetLoader.load_resource(
		path, 
		SettingsSaveData
	) as SettingsSaveData

	# Contingency
	var resave: bool = false
	if not data:
		_warn_no_save_at_path(path)
		resave = true
		data = AssetLoader.load_resource(
			Constants.Paths.Data.NEW_SETTINGS_SAVE, 
			SettingsSaveData
		) as SettingsSaveData
		
		if not data: 
			_error_failed_to_load(path)
			return null
	
	# Update
	_data_to_settings(data)
	
	# Resave
	if resave:
		save_settings(data)
	
	return data

# ===
# Private
# ===

func _game_to_data(data: GameSaveData) -> void:
	# --- Progression ---
	data.chest_queue = progression_context.chest_queue
	
	# --- Player ---
	# Inventory
	data.player_block_items = player_context.block_items
	data.player_block_capacity = player_context.block_capacity
	data.player_boat = player_context.equipped_boat
	data.player_tool = player_context.equipped_tool
	data.player_gold = player_context.gold
	
	# Transforms
	data.player_world_location = player_context.world_location
	data.player_boat_direction = player_context.boat_direction
	data.player_look_direction = player_context.look_direction
	
	# --- World ---
	data.world_seed = world_context.noise_seed
	data.world_time = world_context.time
	data.world_cpu_time = world_context.cpu_time
	data.world_day_phase = world_context.day_phase
	data.world_generation_height = world_context.generation_height

func _data_to_game(data: GameSaveData) -> void:
	# --- Progression ---
	progression_context.chest_queue = data.chest_queue.duplicate(true)
	
	# --- Player ---
	# Inventory
	player_context.block_items = data.player_block_items.duplicate(true)
	player_context.block_capacity = data.player_block_capacity
	player_context.equipped_boat = data.player_boat
	player_context.equipped_tool = data.player_tool
	player_context.gold = data.player_gold
	
	# Transform
	player_context.world_location = data.player_world_location
	player_context.boat_direction = data.player_boat_direction
	player_context.look_direction = data.player_look_direction

	# --- World ---
	world_context.noise_seed = data.world_seed
	world_context.time = data.world_time
	world_context.cpu_time = data.world_cpu_time
	world_context.day_phase = data.world_day_phase
	world_context.generation_height = data.world_generation_height

func _settings_to_data(data: SettingsSaveData) -> void:
	# Audio
	data.master_volume = settings_context.master_volume
	data.music_volume = settings_context.music_volume
	data.sfx_volume = settings_context.sfx_volume
	data.muted_buses = settings_context.muted_buses
	
	# Controls
	data.mouse_sensitivity_x = settings_context.mouse_sensitivity_x
	data.mouse_sensitivity_y = settings_context.mouse_sensitivity_y

	# Gameplay
	data.autosave_enabled = settings_context.autosave_enabled
	data.auto_save_frequency = settings_context.auto_save_frequency

	# Visuals
	data.gui_scale = settings_context.gui_scale
	data.render_quality = settings_context.render_quality
	data.render_distance = settings_context.render_distance

func _data_to_settings(data: SettingsSaveData) -> void:
	# Audio
	settings_context.master_volume = data.master_volume
	settings_context.music_volume = data.music_volume
	settings_context.sfx_volume = data.sfx_volume
	settings_context.muted_buses = data.muted_buses
	
	# Controls
	settings_context.mouse_sensitivity_x = data.mouse_sensitivity_x
	settings_context.mouse_sensitivity_y = data.mouse_sensitivity_y

	# Gameplay
	settings_context.autosave_enabled = data.autosave_enabled
	settings_context.auto_save_frequency = data.auto_save_frequency

	# Visuals
	settings_context.gui_scale = data.gui_scale
	settings_context.render_quality = data.render_quality
	settings_context.render_distance = data.render_distance

func _current_timestamp() -> String:
	var dt := Time.get_datetime_dict_from_system(true)
	
	return (
		"%04d%02d%02d_%02d%02d%02d_%03d"
		% [
			dt.year,
			dt.month,
			dt.day,
			dt.hour,
			dt.minute,
			dt.second,
			Time.get_ticks_msec() % 1000
		]
	)

func _warn_no_save_at_path(path: String) -> void:
	push_warning(
		"Save Provider: No save data found at path ({0}). Creating new entry."
		.format([path])
	)

func _error_failed_to_save(error: int) -> void:
	push_error(
		"SaveProvider: Failed to save. \nError: {0}"
		.format([error_string(error)])
	)

func _error_failed_to_load(path: String) -> void:
	push_error("SaveProvider: Failed to load. Path: %s" % path)
