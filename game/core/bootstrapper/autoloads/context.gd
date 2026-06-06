extends Node

'''
Singleton context for global systems
'''

var ui: UIContext
var world: WorldContext
var progression: ProgressionContext

# ===
# Built-In
# ===

func _ready() -> void:
	ui = UIContext.new()
	world = WorldContext.new()
	progression = ProgressionContext.new()

# ===
# Public
# ===
