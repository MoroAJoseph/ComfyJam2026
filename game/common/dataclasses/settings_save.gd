class_name SettingsSaveData
extends Resource

@export_category("Audio")
@export_range(0.0, 1.0, 0.01) var master_volume: float
@export_range(0.0, 1.0, 0.01) var music_volume: float
@export_range(0.0, 1.0, 0.01) var sfx_volume: float
@export var muted_buses: int

@export_category("Controls")
@export_range(0.0, 1.0, 0.01) var mouse_sensitivity_x: float
@export_range(0.0, 1.0, 0.01) var mouse_sensitivity_y: float

@export_category("Gameplay")
@export var autosave_enabled: bool
@export_range(1, 60, 1) var auto_save_frequency: int # Every X Minutes

@export_category("Visual")
@export var gui_scale: Enums.GUIScale
@export var render_quality: Enums.RenderQuality
@export_range(Constants.MIN_RENDER_DISTANCE, Constants.MAX_RENDER_DISTANCE, 1) var render_distance: int
