class_name WorldContext
extends ContextData

enum Var {
	CHUNK_SIZE,
	TIME,
	SEA_TIME,
	DAY_PHASE,
	NOISE_SEED,
	GENERATION_HEIGHT
}

const DEFAULT: Dictionary[Var, Variant] = {
	Var.CHUNK_SIZE: 64,
	Var.TIME: 0.0,
	Var.SEA_TIME: 0.0,
	Var.DAY_PHASE: Enums.DayPhase.DAWN,
	Var.NOISE_SEED: 12345,
	Var.GENERATION_HEIGHT: 100
}

# ===
# Runtime
# ===

signal chunks_data_updated(value: Dictionary[Vector3i, PackedByteArray])
var chunks_data: Dictionary[Vector3i, PackedByteArray]

signal chunk_size_updated(value: int)
var chunk_size: int:
	set(value):
		chunk_size = value
		chunk_size_updated.emit(value)

signal sea_instance_updated(value: WorldSea)
var sea_instance: WorldSea:
	set(value):
		sea_instance = value
		sea_instance_updated.emit(value)

var land_generated: bool = false

# ===
# Persistent
# ===

signal time_updated(value: float)
var time: float:
	set(value):
		time = value
		time_updated.emit(value)

var sea_time: float

signal day_phase_updated(value: Enums.DayPhase)
var day_phase: Enums.DayPhase:
	set(value):
		day_phase = value
		day_phase_updated.emit(value)

signal noise_seed_updated(value: int)
var noise_seed: int:
	set(value):
		noise_seed = value
		noise_seed_updated.emit(value)

signal generation_height_updated(value: int)
var generation_height: int:
	set(value):
		generation_height = value
		generation_height_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	# Runtime
	chunks_data.clear()
	chunks_data_updated.emit(chunks_data)
	land_generated = false
	sea_instance = null
	
	# Persistent
	chunk_size = DEFAULT[Var.CHUNK_SIZE]
	time = DEFAULT[Var.TIME]
	sea_time = DEFAULT[Var.SEA_TIME]
	day_phase = DEFAULT[Var.DAY_PHASE] as Enums.DayPhase
	noise_seed = DEFAULT[Var.NOISE_SEED]
	generation_height = DEFAULT[Var.GENERATION_HEIGHT]

func to_dict() -> Dictionary[int, Variant]:
	return {
		Var.CHUNK_SIZE: chunk_size,
		Var.TIME: time,
		Var.SEA_TIME: sea_time,
		Var.DAY_PHASE: day_phase,
		Var.NOISE_SEED: noise_seed,
		Var.GENERATION_HEIGHT: generation_height
	}

func from_dict(data: Dictionary[int, Variant]) -> void:
	chunk_size = data.get(Var.CHUNK_SIZE, DEFAULT[Var.CHUNK_SIZE])
	time = data.get(Var.TIME, DEFAULT[Var.TIME])
	sea_time = data.get(Var.SEA_TIME, DEFAULT[Var.SEA_TIME])
	day_phase = data.get(Var.DAY_PHASE, DEFAULT[Var.DAY_PHASE]) as Enums.DayPhase
	noise_seed = data.get(Var.NOISE_SEED, DEFAULT[Var.NOISE_SEED])
	generation_height = data.get(Var.GENERATION_HEIGHT, DEFAULT[Var.GENERATION_HEIGHT])

# ===
# Public
# ===

func get_sea_height(from_position: Vector3) -> float:
	if sea_instance:
		return sea_instance.get_height(from_position, sea_time)
	push_error("WorldContext: No sea instance assigned.")
	return 0.0
