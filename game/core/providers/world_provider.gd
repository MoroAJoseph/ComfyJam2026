class_name WorldProvider
extends ContextProvider

var context: WorldContext

# ===
# Built-In
# ===

func _init(p_context: WorldContext) -> void:
	context = p_context

# ===
# Public
# ===

func update_time(value: float) -> void:
	context.time = value

func update_cpu_time(value: float) -> void:
	context.cpu_time = value

func set_sea(value: WorldSea) -> void:
	context.sea_instance = value

func get_sea_height(from_position: Vector3) -> float:
	if context.sea_instance:
		return context.sea_instance.get_height(from_position, context.cpu_time)
	push_error("WorldProvider: No sea instance assigned.")
	return 0.0
