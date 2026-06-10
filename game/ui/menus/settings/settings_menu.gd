extends Control

@onready var volume_slider: HSlider = %VolumeSlider
@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var volume_value_label: Label = %VolumeValue
@onready var sensitivity_input: LineEdit = %SensitivityValue

# ===
# Built-in
# ===

func _ready() -> void:
	pass
	## Initialize sliders
	#volume_slider.value = Session.settings_context.master_volume
	#sensitivity_slider.value = Session.settings_context.mouse_sensitivity
	#
	## Update labels
	#_update_volume_label(volume_slider.value)
	#_update_sensitivity_display(sensitivity_slider.value)
	#
	## Connect signals
	#volume_slider.value_changed.connect(_on_volume_changed)
	#sensitivity_slider.value_changed.connect(_on_sensitivity_slider_changed)
	#sensitivity_input.text_submitted.connect(_on_sensitivity_text_submitted)
	#sensitivity_input.focus_exited.connect(_on_sensitivity_focus_exited)

# ===
# Signals
# ===

func _on_volume_changed(value: float) -> void:
	Session.settings_context.master_volume = value
	Session.settings_provider.apply_settings()
	_update_volume_label(value)

func _on_sensitivity_slider_changed(value: float) -> void:
	Session.settings_context.mouse_sensitivity = value
	_update_sensitivity_display(value)

func _on_sensitivity_text_submitted(new_text: String) -> void:
	_apply_text_sensitivity(new_text)

func _on_sensitivity_focus_exited() -> void:
	_apply_text_sensitivity(sensitivity_input.text)

func _on_back_pressed() -> void:
	EventBus.emit(
		GameEvent.SaveSettings.new()
	)
	
	EventBus.emit(
		UIEvent.SettingsMenu.new(
			Enums.SettingsMenuAction.CLOSE
		)
	)

# ===
# Private
# ===

func _update_volume_label(value: float) -> void:
	volume_value_label.text = str(round(value * 100)) + "%"

func _update_sensitivity_display(value: float) -> void:
	sensitivity_input.text = "%.3f" % value

func _apply_text_sensitivity(text: String) -> void:
	var value := text.to_float()
	# Clamp to slider range
	value = clamp(value, sensitivity_slider.min_value, sensitivity_slider.max_value)
	
	Session.settings_context.mouse_sensitivity = value
	sensitivity_slider.value = value
	_update_sensitivity_display(value)
