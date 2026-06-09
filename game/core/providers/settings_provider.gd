class_name SettingsProvider
extends RefCounted

var settings_context: SettingsContext

func _init(p_settings: SettingsContext) -> void:
	settings_context = p_settings

func save_settings() -> void:
	var settings_resource := SettingsData.new()
	settings_resource.master_volume = settings_context.master_volume
	settings_resource.mouse_sensitivity = settings_context.mouse_sensitivity
	
	var error := ResourceSaver.save(settings_resource, Constants.Paths.Data.USER_SETTINGS)
	if error != OK:
		push_error("SettingsProvider: Failed to save settings. Error code: %d" % error)

func load_settings() -> void:
	if not FileAccess.file_exists(Constants.Paths.Data.USER_SETTINGS):
		# No settings file, apply defaults and save them
		apply_settings()
		save_settings()
		return

	var settings_resource := AssetLoader.load_resource(Constants.Paths.Data.USER_SETTINGS, SettingsData) as SettingsData
	if not settings_resource:
		push_error("SettingsProvider: Failed to load settings resource.")
		return
		
	settings_context.master_volume = settings_resource.master_volume
	settings_context.mouse_sensitivity = settings_resource.mouse_sensitivity
	
	apply_settings()

func apply_settings() -> void:
	# Apply Audio
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(settings_context.master_volume))
	
	# Mouse sensitivity is reactive, consumed by the camera controller
