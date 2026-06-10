class_name AudioController
extends Node

@onready var background_music: AudioStreamPlayer = %BackgroundMusic
@onready var sfx: Node3D = %SFX

# ===
# Built-In
# ===

func _ready() -> void:
	Session.settings_context.master_volume_updated.connect(_on_master_volume_updated)
	Session.settings_context.music_volume_updated.connect(_on_music_volume_updated)
	Session.settings_context.sfx_volume_updated.connect(_on_sfx_volume_updated)
	Session.settings_context.muted_buses_updated.connect(_on_muted_buses_updated)

# ===
# Signals
# ===

func _on_master_volume_updated(value: float) -> void:
	pass

func _on_music_volume_updated(value: float) -> void:
	pass

func _on_sfx_volume_updated(value: float) -> void:
	pass

func _on_muted_buses_updated(value: int) -> void:
	pass
