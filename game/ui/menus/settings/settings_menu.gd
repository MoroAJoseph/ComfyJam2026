extends Control

@onready var volume_slider: HSlider = %VolumeSlider
@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var volume_value_label: Label = %VolumeValue
@onready var sensitivity_value_label: Label = %SensitivityValue

# ===
# Built-in
# ===

func _ready() -> void:
	# Initialize sliders
	volume_slider.value = Session.settings_context.master_volume
	sensitivity_slider.value = Session.settings_context.mouse_sensitivity
	
	# Update labels
	_update_volume_label(volume_slider.value)
	_update_sensitivity_label(sensitivity_slider.value)
	
	# Connect signals
	volume_slider.value_changed.connect(_on_volume_changed)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

# ===
# Signals
# ===

func _on_volume_changed(value: float) -> void:
	Session.settings_context.master_volume = value
	Session.settings_provider.apply_settings()
	_update_volume_label(value)

func _on_sensitivity_changed(value: float) -> void:
	Session.settings_context.mouse_sensitivity = value
	_update_sensitivity_label(value)

func _on_back_pressed() -> void:
	Session.settings_provider.save_settings()
	EventBus.emit(UIEvent.SettingsMenu.new(Enums.SettingsMenuAction.CLOSE))

# ===
# Private
# ===

func _update_volume_label(value: float) -> void:
	volume_value_label.text = str(round(value * 100)) + "%"

func _update_sensitivity_label(value: float) -> void:
	sensitivity_value_label.text = "%.3f" % value
