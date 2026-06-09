class_name NarrativeContext
extends ContextData

'''
All progress tracking for narrative features will go here.
Used by the dialogue system to handle branching logic.
'''

enum Var {
	
}
const DEFAULT: Dictionary[Var, Variant] = {
	
}

# ===
# Runtime
# ===

# ===
# Persistent
# ===

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	return

func to_dict() -> Dictionary[int, Variant]:
	return {
		
	}

func from_dict(_data: Dictionary[int, Variant]) -> void:
	return

# ===
# Public
# ===

# ===
# Private
# ===
