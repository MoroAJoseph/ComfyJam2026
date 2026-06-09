extends Node

# Runtime
var version_string: String
var did_bootsplash: bool = false
var is_in_world: bool = false

# Context
var narrative_context: NarrativeContext
var progression_context: ProgressionContext
var ui_context: UIContext
var world_context: WorldContext
var player_context: PlayerContext

# Providers
var save_provider: SaveProvider
var progression_provider: ProgressionProvider

func _init() -> void:
	# Context
	narrative_context = NarrativeContext.new()
	progression_context = ProgressionContext.new()
	ui_context = UIContext.new()
	world_context = WorldContext.new()
	player_context = PlayerContext.new()
	
	# Providers
	progression_provider = ProgressionProvider.new(
		progression_context, 
		player_context
	)
	
	save_provider = SaveProvider.new(
		progression_context, 
		player_context, 
		world_context
	)
	
	# Reset
	reset()

func reset() -> void:
	did_bootsplash = false
	is_in_world = false
	
	# Context
	narrative_context.reset()
	progression_context.reset()
	ui_context.reset()
	world_context.reset()
	player_context.reset()
