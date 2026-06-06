class_name TimeController
extends Node

## Current internal time in seconds
var _current_time: float = 0.0

# ===
# Built-In
# ===

func _ready() -> void:
	# Initialize from context if we are loading a game
	_current_time = Context.world.day_time

func _process(delta: float) -> void:
	if not Context.session.is_in_world:
		return
	
	_current_time += delta
	
	# Wrap around the day
	if _current_time >= Constants.DAY_DURATION:
		_current_time -= Constants.DAY_DURATION
		Context.world.days_passed += 1
	
	# Update Context
	Context.world.day_time = _current_time
	Context.world.time_ratio = _current_time / Constants.DAY_DURATION
	
	# Emit event for systems that don't want to poll every frame
	# Note: For performance, you might want to emit this less frequently 
	# (e.g. every 1 second of game time)
	EventBus.emit(GameEvent.TimeUpdated.new(Context.world.time_ratio))
