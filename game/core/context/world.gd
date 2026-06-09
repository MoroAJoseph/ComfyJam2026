class_name WorldContext
extends RefCounted

# Time
var time: float
var day_phase: Enums.DayPhase

# Sea
var sea_time: float
var sea_instance: WorldSea

# Land
var chunks_data: Dictionary[Vector3i, PackedByteArray] = {}
var chunk_size: int = 64
var noise_seed: int = 0
var generation_height: int = 16
var land_generated: bool = false

# --- Time ---


# --- Sea ---
func get_sea_height(from_position: Vector3) -> float:
	if sea_instance:
		return sea_instance.get_height(from_position, sea_time)
	else:
		push_error("No sea instance")
		return 0.0

# --- Land ---
