class_name EnvironmentController
extends Node3D

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $Sun

@export_category("Light Colors")
@export var day_color := Color("fff4d6")
@export var sunset_color := Color("f9814a")
@export var night_color := Color("1b2632")

@export_category("Sky Colors")
@export var sky_top_day := Color("4a90e2")
@export var sky_horizon_day := Color("a5d8ff")
@export var sky_top_night := Color("050b1a")
@export var sky_horizon_night := Color("1a2b45")

@export var sun_max_energy := 1.2
@export var night_energy := 0.1

# ===
# Built-In
# ===

func _ready() -> void:
	EventBus.subscribe(GameEvent.TimeUpdated, _on_time_updated)
	_update_environment(Context.world.time_ratio)

func _exit_tree() -> void:
	EventBus.unsubscribe(GameEvent.TimeUpdated, _on_time_updated)

# ===
# Private
# ===

func _update_environment(ratio: float) -> void:
	# Rotate sun
	var angle = (ratio * 360.0) - 90.0
	sun.rotation_degrees.x = -angle
	
	# Get sky material
	var sky_mat: ProceduralSkyMaterial = world_env.environment.sky.sky_material
	
	# Day/Night intensity
	# 0.2 to 0.8 is day, peaks at 0.5
	var day_weight = clamp(1.0 - abs(ratio - 0.5) * 4.0, 0.0, 1.0)
	
	# Update Sun
	if ratio > 0.2 and ratio < 0.8:
		sun.light_color = day_color.lerp(sunset_color, 1.0 - day_weight)
		sun.light_energy = lerp(night_energy, sun_max_energy, day_weight)
	else:
		sun.light_color = night_color
		sun.light_energy = night_energy
	
	# Update Sky Colors
	sky_mat.sky_top_color = sky_top_night.lerp(sky_top_day, day_weight)
	sky_mat.sky_horizon_color = sky_horizon_night.lerp(sky_horizon_day, day_weight)
	sky_mat.ground_horizon_color = sky_mat.sky_horizon_color

# ===
# Event Handlers
# ===

func _on_time_updated(event: GameEvent.TimeUpdated) -> void:
	_update_environment(event.time_ratio)
