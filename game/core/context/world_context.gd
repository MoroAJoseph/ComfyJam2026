class_name WorldContext
extends ContextData

enum Var {
	CHUNK_SIZE,
	TIME,
	DAY_PHASE,
	NOISE_SEED,
	GENERATION_HEIGHT
}

const DEFAULT: Dictionary[Var, Variant] = {
	Var.CHUNK_SIZE: 64,
	Var.TIME: 0.35,
	Var.DAY_PHASE: Enums.DayPhase.DAWN,
	Var.NOISE_SEED: 12345,
	Var.GENERATION_HEIGHT: 48
}

# ===
# Runtime
# ===

signal chunks_data_updated(value: Dictionary[Vector3i, PackedByteArray])
var _chunks_data: Dictionary[Vector3i, PackedByteArray]
var chunks_data: Dictionary[Vector3i, PackedByteArray]:
	get: return _chunks_data
	set(value):
		_chunks_data = value
		chunks_data_updated.emit(value)

# --- Chunk Size ---
signal chunk_size_updated(value: int)
var _chunk_size: int
var chunk_size: int:
	get: return _chunk_size
	set(value):
		if _authorize_write():
			_chunk_size = value
			chunk_size_updated.emit(value)

# --- Sea ---
signal sea_instance_updated(value: WorldSea)
var _sea_instance: WorldSea
var sea_instance: WorldSea:
	get: return _sea_instance
	set(value):
		if _authorize_write():
			_sea_instance = value
			sea_instance_updated.emit(value)

# --- Land Generated ---
signal land_generated_udpated(value: bool)
var _land_generated: bool
var land_generated: bool:
	get: return _land_generated
	set(value):
		_land_generated = value
		land_generated_udpated.emit(value)

# --- Day Phase ---
signal day_phase_updated(value: Enums.DayPhase)
var _day_phase: Enums.DayPhase
var day_phase: Enums.DayPhase:
	get: return _day_phase
	set(value):
		if _authorize_write():
			_day_phase = value
			day_phase_updated.emit(_day_phase)

# ===
# Persistent
# ===

# --- Time ---
signal time_updated(value: float)
var _time: float
var time: float:
	get: return _time
	set(value):
		if _authorize_write():
			_time = value
			time_updated.emit(value)

# --- CPU Time ---
signal cpu_time_updated(value: float)
var _cpu_time: float
var cpu_time: float:
	get: return _cpu_time
	set(value):
		if _authorize_write():
			_cpu_time = value
			cpu_time_updated.emit(value)

# --- Noise Seed ---
signal noise_seed_updated(value: int)
var _noise_seed: int
var noise_seed: int:
	get: return _noise_seed
	set(value):
		if _authorize_write():
			_noise_seed = value
			noise_seed_updated.emit(_noise_seed)

# --- Generation Height ---
signal generation_height_updated(value: int)
var _generation_height: int
var generation_height: int:
	get: return _generation_height
	set(value):
		if _authorize_write():
			_generation_height = value
			generation_height_updated.emit(_generation_height)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	_chunks_data.clear()
	chunks_data_updated.emit(chunks_data)
	_sea_instance = null
	_land_generated = false
	_day_phase = DEFAULT[Var.DAY_PHASE] as Enums.DayPhase
	
	_chunk_size = DEFAULT[Var.CHUNK_SIZE]
	_time = DEFAULT[Var.TIME]
	_noise_seed = DEFAULT[Var.NOISE_SEED]
	_generation_height = DEFAULT[Var.GENERATION_HEIGHT]
