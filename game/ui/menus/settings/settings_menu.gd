extends Control

@onready var volume_slider: HSlider = %VolumeSlider
@onready var sensitivity_slider: HSlider = %SensitivitySlider

# ===
# Built-in
# ===

func _ready() -> void:
	# Initialize sliders
	volume_slider.value = Session.settings_context.master_volume
	sensitivity_slider.value = Session.settings_context.mouse_sensitivity
	
	# Connect signals
	volume_slider.value_changed.connect(_on_volume_changed)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

# ===
# Signals
# ===

func _on_volume_changed(value: float) -> void:
	Session.settings_context.master_volume = value
	Session.settings_provider.apply_settings()

func _on_sensitivity_changed(value: float) -> void:
	Session.settings_context.mouse_sensitivity = value

func _on_back_pressed() -> void:
	Session.settings_provider.save_settings()
	EventBus.emit(UIEvent.SettingsMenu.new(Enums.SettingsMenuAction.CLOSE))
