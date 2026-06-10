@tool
class_name WorldSky
extends Node3D

@export_group("Gradients")
@export var top_color_grad: GradientTexture1D
@export var bottom_color_grad: GradientTexture1D
@export var clouds_light_grad: GradientTexture1D
@export var sun_tint_grad: GradientTexture1D
@export var sun_scatter_grad: GradientTexture1D
@export var sun_light_grad: GradientTexture1D
@export var moon_tint_grad: GradientTexture1D

@export_group("Curves")
@export var cloud_density_curve: Curve
@export var cloud_scale_curve: Curve
@export var cloud_smoothness_curve: Curve
@export var cloud_shadow_curve: Curve
@export var high_clouds_curve: Curve
@export var stars_intensity_curve: Curve
@export var shooting_stars_curve: Curve
@export var sun_intensity_curve: Curve
@export var sun_scale_curve: Curve
@export var moon_intensity_curve: Curve
@export var moon_scale_curve: Curve

@export_group("Settings")
@export var simulate: bool = false
@export var base_day_duration: float = 86400.0
@export var time_scale: float = 1440.0
@export_range(0.0, 1.0, 0.01) var day_progress: float = 0.0:
	set(value):
		day_progress = value
		_update_visuals()
@export var moon_direction: Vector3 = Vector3(0.0, 0.5, 0.5)

@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var sun_pivot: Node3D = %SunPivot
@onready var sun_light: DirectionalLight3D = %SunLight

var shader: ShaderMaterial

func _ready() -> void:
	if world_environment and world_environment.environment and world_environment.environment.sky:
		var matterial: Material = world_environment.environment.sky.sky_material
		if matterial is ShaderMaterial: shader = matterial

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not simulate: return
	
	if not Engine.is_editor_hint():
		day_progress = Session.world_context.time
	else:
		day_progress = fmod(day_progress + (delta * time_scale) / base_day_duration, 1.0)
	
	_update_visuals()

func _update_visuals() -> void:
	if not shader: return
	
	# Sun
	if sun_pivot:
		sun_pivot.rotation_degrees = Vector3(
			(day_progress * 360.0) + 90.0, 
			-90.0, 
			-90.0
		)
	
	if sun_light and sun_light_grad:
		sun_light.light_color = sun_light_grad.gradient.sample(day_progress)
	if sun_light and sun_intensity_curve:
		sun_light.light_energy = sun_intensity_curve.sample(day_progress)
	
	# Moon
	shader.set_shader_parameter("moon_direction", moon_direction)
	
	# Gradients
	if top_color_grad: shader.set_shader_parameter("top_color", top_color_grad.gradient.sample(day_progress))
	if bottom_color_grad: shader.set_shader_parameter("bottom_color", bottom_color_grad.gradient.sample(day_progress))
	if sun_scatter_grad: shader.set_shader_parameter("sun_scatter", sun_scatter_grad.gradient.sample(day_progress))
	if clouds_light_grad: shader.set_shader_parameter("clouds_light_color", clouds_light_grad.gradient.sample(day_progress))
	if sun_tint_grad: shader.set_shader_parameter("sun_tint", sun_tint_grad.gradient.sample(day_progress))
	if moon_tint_grad: shader.set_shader_parameter("moon_tint", moon_tint_grad.gradient.sample(day_progress))

	# Curves
	if cloud_density_curve: shader.set_shader_parameter("clouds_density", cloud_density_curve.sample(day_progress))
	if cloud_scale_curve: shader.set_shader_parameter("clouds_scale", cloud_scale_curve.sample(day_progress))
	if cloud_smoothness_curve: shader.set_shader_parameter("clouds_smoothness", cloud_smoothness_curve.sample(day_progress))
	if cloud_shadow_curve: shader.set_shader_parameter("clouds_shadow_intensity", cloud_shadow_curve.sample(day_progress))
	if high_clouds_curve: shader.set_shader_parameter("high_clouds_density", high_clouds_curve.sample(day_progress))
	if stars_intensity_curve: shader.set_shader_parameter("stars_intensity", stars_intensity_curve.sample(day_progress))
	if shooting_stars_curve: shader.set_shader_parameter("shooting_stars_intensity", shooting_stars_curve.sample(day_progress))
	if sun_scale_curve: shader.set_shader_parameter("sun_scale", sun_scale_curve.sample(day_progress))
	if moon_intensity_curve: shader.set_shader_parameter("moon_intensity", moon_intensity_curve.sample(day_progress))
	if moon_scale_curve: shader.set_shader_parameter("moon_scale", moon_scale_curve.sample(day_progress))
	
	
	
