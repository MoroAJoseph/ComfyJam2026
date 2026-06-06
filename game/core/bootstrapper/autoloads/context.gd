extends Node

'''
Singleton context for global systems
'''

var session: SessionContext
var progression: ProgressionContext
var ui: UIContext
var world: WorldContext
var player: PlayerContext

# ===
# Built-In
# ===

func _ready() -> void:
	session = SessionContext.new()
	progression = ProgressionContext.new()
	ui = UIContext.new()
	world = WorldContext.new()
	player = PlayerContext.new()

# ===
# Public
# ===
