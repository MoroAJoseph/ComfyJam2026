extends Node

# Runtime
var version_string: String
var did_bootsplash: bool = false
var is_in_world: bool = false

# Context
var settings_context: SettingsContext
var narrative_context: NarrativeContext
var progression_context: ProgressionContext
var ui_context: UIContext
var world_context: WorldContext
var player_context: PlayerContext

# Providers
var save_provider: SaveProvider
var settings_provider: SettingsProvider
var narrative_provider: NarrativeProvider
var progression_provider: ProgressionProvider
var ui_provider: UIProvider
var world_provider: WorldProvider
var player_provider: PlayerProvider

func _init() -> void:
	# Context
	settings_context = SettingsContext.new()
	narrative_context = NarrativeContext.new()
	progression_context = ProgressionContext.new()
	settings_context = SettingsContext.new()
	ui_context = UIContext.new()
	world_context = WorldContext.new()
	player_context = PlayerContext.new()
	
	# Providers
	save_provider = SaveProvider.new(
		settings_context,
		progression_context, 
		player_context, 
		world_context
	)
	
	settings_provider = SettingsProvider.new(
		settings_context
	)

	progression_provider = ProgressionProvider.new(
		progression_context, 
		player_context
	)
	
	ui_provider = UIProvider.new(
		ui_context
	)
	
	world_provider = WorldProvider.new(
		world_context
	)
	
	player_provider = PlayerProvider.new(
		player_context
	)
	
	# Reset
	reset()

func reset() -> void:
	did_bootsplash = false
	is_in_world = false
	
	# Context
	narrative_context.reset()
	progression_context.reset()
	settings_context.reset()
	ui_context.reset()
	world_context.reset()
	player_context.reset()
