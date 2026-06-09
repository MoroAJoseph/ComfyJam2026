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
var chest_queue: Array[Enums.ChestType] = []:
	set(value):
		chest_queue = value
		chest_queue_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	chest_queue.clear()

func to_dict() -> Dictionary[int, Variant]:
	return {
		Var.CHEST_QUEUE: chest_queue,
	}

func from_dict(data: Dictionary[int, Variant]) -> void:
	# Handle Array
	var loaded_queue: Array[Enums.ChestType] = data.get(Var.CHEST_QUEUE, [])
	chest_queue.assign(loaded_queue)
	
	chest_queue_updated.emit(chest_queue)

# ===
# Public API
# ===



# ===
# Private
# ===
