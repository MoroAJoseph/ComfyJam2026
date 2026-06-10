class_name ProgressionContext
extends ContextData

enum Var {
	CHEST_QUEUE,
}

const DEFAULT: Dictionary[Var, Variant] = {
	Var.CHEST_QUEUE: [],
}

# ===
# Runtime
# ===


# ===
# Persistent
# ===

# --- Chest Queue ---
signal chest_queue_updated(value: Array[Enums.ChestType])
var _chest_queue: Array[Enums.ChestType] = []
var chest_queue: Array[Enums.ChestType] = []:
	get: return _chest_queue
	set(value):
		_chest_queue = value
		chest_queue_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	_chest_queue.clear()

# ===
# Public API
# ===



# ===
# Private
# ===
