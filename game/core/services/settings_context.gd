class_name SettingsContext
extends ContextData

enum Var {
	MASTER_VOLUME,
	MOUSE_SENSITIVITY,
}

const DEFAULT: Dictionary[Var, Variant] = {
	Var.MASTER_VOLUME: 1.0,
	Var.MOUSE_SENSITIVITY: 0.005,
}

# ===
# Persistent
# ===

signal master_volume_updated(value: float)
var master_volume: float = 1.0:
	set(value):
		master_volume = value
		master_volume_updated.emit(value)

signal mouse_sensitivity_updated(value: float)
var mouse_sensitivity: float = 0.005:
	set(value):
		mouse_sensitivity = value
		mouse_sensitivity_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	master_volume = DEFAULT[Var.MASTER_VOLUME]
	mouse_sensitivity = DEFAULT[Var.MOUSE_SENSITIVITY]

func to_dict() -> Dictionary[int, Variant]:
	return {
		Var.MASTER_VOLUME: master_volume,
		Var.MOUSE_SENSITIVITY: mouse_sensitivity,
	}

func from_dict(data: Dictionary[int, Variant]) -> void:
	master_volume = data.get(Var.MASTER_VOLUME, DEFAULT[Var.MASTER_VOLUME])
	mouse_sensitivity = data.get(Var.MOUSE_SENSITIVITY, DEFAULT[Var.MOUSE_SENSITIVITY])
