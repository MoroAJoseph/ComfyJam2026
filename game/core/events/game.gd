class_name GameEvent
extends Event

# --- Title ---
class LoadTitle extends GameEvent: pass
class TitleLoaded extends GameEvent: pass

# --- World ---
class LoadWorld extends GameEvent: pass
class WorldLoaded extends GameEvent: pass

# --- Pause ---
class PausedUpdated extends GameEvent:
	
	var is_paused: bool
	
	func _init(
		p_is_paused: bool
	):
		is_paused = p_is_paused
