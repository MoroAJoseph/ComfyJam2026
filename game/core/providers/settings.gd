class_name SettingsProvider
extends ContextProvider

var context: SettingsContext

const BusMuteFlag := {
	Enums.AudioBus.MASTER: 1 << 0,
	Enums.AudioBus.MUSIC: 1 << 1,
	Enums.AudioBus.SFX: 1 << 2,
}

# ===
# Built-In
# ===

func _init(p_context: SettingsContext) -> void:
	context = p_context

# ===
# Public
# ===

# --- Audio ---
func set_volume(bus: Enums.AudioBus, value: float) -> void:
	value = clampf(value, 0.0, 1.0)
	
	match bus:
		Enums.AudioBus.MASTER:
			context.master_volume = value
		Enums.AudioBus.MUSIC:
			context.music_volume = value
		Enums.AudioBus.SFX:
			context.sfx_volume = value

func set_bus_mute(bus: Enums.AudioBus, value: bool) -> void:
	var flags := context.muted_buses
	var mask: int = BusMuteFlag[bus]

	if value:
		flags |= mask
	else:
		flags &= ~mask

	context.muted_buses = flags

func is_bus_muted(bus: Enums.AudioBus) -> bool:
	var mask: int = BusMuteFlag[bus]
	return (context.muted_buses & mask) != 0

# --- Controls ---
func set_mouse_sensitivity(value: Vector2) -> void:
	context.mouse_sensitivity_x = clampf(value.x, 0.0, 1.0)
	context.mouse_sensitivity_y = clampf(value.y, 0.0, 1.0)

func get_mouse_sensitivity() -> Vector2:
	return Vector2(
		context.mouse_sensitivity_x,
		context.mouse_sensitivity_y
	)

# --- Gameplay ---
func set_autosave_enabled(value: bool) -> void:
	context.autosave_enabled = value

func set_auto_save_frequency(value: int) -> void:
	context.auto_save_frequency = maxi(value, 1)

# --- Visuals ---
func set_gui_scale(value: Enums.GUIScale) -> void:
	context.gui_scale = value

func set_render_quality(value: Enums.RenderQuality) -> void:
	context.render_quality = value

func set_render_distance(value: int) -> void:
	context.render_distance = clampi(
		value,
		Constants.MIN_RENDER_DISTANCE,
		Constants.MAX_RENDER_DISTANCE
	)
