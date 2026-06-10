class_name SettingsContext
extends ContextData

enum Var {
	# Audio
	MASTER_VOLUME,
	MUSIC_VOLUME,
	SFX_VOLUME,
	MUTED_BUSES,

	# Controls
	MOUSE_SENSITIVITY_X,
	MOUSE_SENSITIVITY_Y,

	# Gameplay
	AUTOSAVE_ENABLED,
	AUTO_SAVE_FREQUENCY,

	# Visual
	GUI_SCALE,
	RENDER_QUALITY,
	RENDER_DISTANCE,
}

const DEFAULT: Dictionary[Var, Variant] = {
	# Audio
	Var.MASTER_VOLUME: 1.0,
	Var.MUSIC_VOLUME: 1.0,
	Var.SFX_VOLUME: 1.0,
	Var.MUTED_BUSES: 0,

	# Controls
	Var.MOUSE_SENSITIVITY_X: 1.0,
	Var.MOUSE_SENSITIVITY_Y: 1.0,

	# Gameplay
	Var.AUTOSAVE_ENABLED: true,
	Var.AUTO_SAVE_FREQUENCY: 1,

	# Visual
	Var.GUI_SCALE: Enums.GUIScale.FULL,
	Var.RENDER_QUALITY: Enums.RenderQuality.HIGH,
	Var.RENDER_DISTANCE: Constants.MIN_RENDER_DISTANCE,
}

# ===
# Runtime
# ===

# ===
# Persistent
# ===

# --- Master Volume ---
signal master_volume_updated(value: float)
var _master_volume: float
var master_volume: float:
	get: return _master_volume
	set(value):
		if _authorize_write():
			_master_volume = value
			master_volume_updated.emit(value)

# --- Music Volume ---
signal music_volume_updated(value: float)
var _music_volume: float
var music_volume: float:
	get: return _music_volume
	set(value):
		if _authorize_write():
			_music_volume = value
			music_volume_updated.emit(value)

# --- SFX Volume ---
signal sfx_volume_updated(value: float)
var _sfx_volume: float
var sfx_volume: float:
	get: return _sfx_volume
	set(value):
		if _authorize_write():
			_sfx_volume = value
			sfx_volume_updated.emit(value)

# --- Muted Buses ---
signal muted_buses_updated(value: int)
var _muted_buses: int
var muted_buses: int:
	get: return _muted_buses
	set(value):
		if _authorize_write():
			_muted_buses = value
			muted_buses_updated.emit(value)

# --- Mouse Sensitivity X ---
signal mouse_sensitivity_x_updated(value: float)
var _mouse_sensitivity_x: float
var mouse_sensitivity_x: float:
	get: return _mouse_sensitivity_x
	set(value):
		if _authorize_write():
			_mouse_sensitivity_x = value
			mouse_sensitivity_x_updated.emit(value)

# --- Mouse Sensitivity Y ---
signal mouse_sensitivity_y_updated(value: float)
var _mouse_sensitivity_y: float
var mouse_sensitivity_y: float:
	get: return _mouse_sensitivity_y
	set(value):
		if _authorize_write():
			_mouse_sensitivity_y = value
			mouse_sensitivity_y_updated.emit(value)

# --- Auto-save Enabled ---
signal autosave_enabled_updated(value: bool)
var _autosave_enabled: bool
var autosave_enabled: bool:
	get: return _autosave_enabled
	set(value):
		if _authorize_write():
			_autosave_enabled = value
			autosave_enabled_updated.emit(value)

# --- Auto-save Frequency ---
signal auto_save_frequency_updated(value: int)
var _auto_save_frequency: int
var auto_save_frequency: int:
	get: return _auto_save_frequency
	set(value):
		if _authorize_write():
			_auto_save_frequency = value
			auto_save_frequency_updated.emit(value)

# --- GUI Scale ---
signal gui_scale_updated(value: Enums.GUIScale)
var _gui_scale: Enums.GUIScale
var gui_scale: Enums.GUIScale:
	get: return _gui_scale
	set(value):
		if _authorize_write():
			_gui_scale = value
			gui_scale_updated.emit(value)

# --- Render Quality ---
signal render_quality_updated(value: Enums.RenderQuality)
var _render_quality: Enums.RenderQuality
var render_quality: Enums.RenderQuality:
	get: return _render_quality
	set(value):
		if _authorize_write():
			_render_quality = value
			render_quality_updated.emit(value)

# --- Render Distance ---
signal render_distance_updated(value: int)
var _render_distance: int
var render_distance: int:
	get: return _render_distance
	set(value):
		if _authorize_write():
			_render_distance = value
			render_distance_updated.emit(value)

# ===
# Built-In
# ===

func _init() -> void:
	reset()

func reset() -> void:
	# Audio
	_master_volume = DEFAULT[Var.MASTER_VOLUME]
	_music_volume = DEFAULT[Var.MUSIC_VOLUME]
	_sfx_volume = DEFAULT[Var.SFX_VOLUME]
	_muted_buses = DEFAULT[Var.MUTED_BUSES]

	# Controls
	_mouse_sensitivity_x = DEFAULT[Var.MOUSE_SENSITIVITY_X]
	_mouse_sensitivity_y = DEFAULT[Var.MOUSE_SENSITIVITY_Y]
	
	# Gameplay
	_autosave_enabled = DEFAULT[Var.AUTOSAVE_ENABLED]
	_auto_save_frequency = DEFAULT[Var.AUTO_SAVE_FREQUENCY]
	
	# Visual
	_gui_scale = DEFAULT[Var.GUI_SCALE] as Enums.GUIScale
	_render_quality = DEFAULT[Var.RENDER_QUALITY] as Enums.RenderQuality
	_render_distance = DEFAULT[Var.RENDER_DISTANCE]
