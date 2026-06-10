class_name PlayerCameraController 
extends Node3D

@export_group("Zoom Settings")
@export var min_zoom: float = 6.0
@export var max_zoom: float = 12.0
@export var zoom_step: float = 2.0
@export var controller_zoom_lerp: float = 10.0

@export_group("Look Settings")
@export_range(-89.0, 0.0) var min_pitch: float = -45.0
@export_range(0.0, 89.0) var max_pitch: float = 20.0
@export var mouse_sensitivity: float = 0.005
@export var invert_horizontal: bool = false
@export var invert_vertical: bool = false
@export var yaw_lerp: float = 5.0
@export var pitch_lerp: float = 5.0

@onready var pitch_pivot = %Pitch
@onready var yaw_pivot = %Yaw
@onready var boom = %Boom
@onready var camera = %Camera

var shake_intensity := 0.0
var shake_duration := 0.0
var follow_target: Node3D
var is_locked: bool = true
var mouse_delta: Vector2 = Vector2.ZERO
var mouse_input: Vector2
var controller_input: Vector2 
var trigger_value: float
var move_direction: Vector2

# ===
# Built-In
# ===

func _ready() -> void:
	# Update Zoom
	var boat_type: Enums.BoatType = Session.player_context.equipped_boat
	if boat_type:
		_update_zoom_values_from_boat(boat_type)
	Session.player_context.equipped_boat_updated.connect(
		func(value: Enums.BoatType):
			_update_zoom_values_from_boat(value)
	)
	
	_update_mouse_mode()
	EventBus.subscribe(WorldEvent.PlayerSpawned, _handle_world_player_spawned)
	EventBus.subscribe(WorldEvent.CameraShake, _handle_camera_shake)

func _input(event: InputEvent) -> void:
	# Scroll Wheel (Zoom)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			boom.spring_length = clamp(boom.spring_length - zoom_step, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			boom.spring_length = clamp(boom.spring_length + zoom_step, min_zoom, max_zoom)
	
	# Camera Mode
	if event.is_action_pressed("camera_mode"):
		is_locked = !is_locked
		_update_mouse_mode()
	
	if (
		not is_locked and 
		event is InputEventMouseMotion
	):
		mouse_delta = event.relative

func _process(delta: float) -> void:
	# Ensure follow target is current
	if Session.player_context.boat_instance != follow_target:
		follow_target = Session.player_context.boat_instance

	if not follow_target: return
	
	# Follow target
	global_position = follow_target.global_position
	
	# Handle Shake
	if shake_duration > 0:
		shake_duration -= delta
		camera.h_offset = randf_range(-shake_intensity, shake_intensity)
		camera.v_offset = randf_range(-shake_intensity, shake_intensity)
	else:
		camera.h_offset = 0.0
		camera.v_offset = 0.0
	
	# Input values
	mouse_input = mouse_delta * mouse_sensitivity
	controller_input = Input.get_vector(
		"camera_left", "camera_right", 
		"camera_up", "camera_down"
	)
	mouse_input += controller_input * delta * 2.0 
	#trigger_value = Input.get_action_strength("camera_zoom")
	
	# Move direction
	move_direction = Vector2(
		-1.0 if not invert_horizontal else 1.0,
		-1.0 if not invert_vertical else 1.0
	)
	
	# Zoom
	#_process_zoom(delta)
	
	# Camera mode
	if is_locked:
		_process_locked(delta)
	else:
		_process_unlocked(delta)
	
	# Update context
	
	Session.player_provider.update_look_direction(-camera.global_transform.basis.z.normalized())

# ===
# Private
# ===

func _update_zoom_values_from_boat(boat_type: Enums.BoatType) -> void:
	var boat_data: BoatData = AssetService.get_boat_data(boat_type)
	if boat_data:
		max_zoom = boat_data.max_zoom
		min_zoom = boat_data.min_zoom
		zoom_step = boat_data.zoom_step
		boom.spring_length = max_zoom

func _update_mouse_mode():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_locked else Input.MOUSE_MODE_CAPTURED)

func _process_zoom(delta: float) -> void:
	
	# Trigger value: 0.0 = Max, 1.0 = Min
	var target_length = lerp(
		max_zoom, 
		min_zoom, 
		trigger_value
	)
	
	# Smoothly move to the target
	boom.spring_length = lerp(
		boom.spring_length, 
		target_length, 
		delta * controller_zoom_lerp
	)

func _process_locked(delta: float) -> void:
	# Horizontal rotation
	var target_yaw: float = follow_target.global_transform.basis.get_euler().y
	yaw_pivot.rotation.y = lerp_angle(
		yaw_pivot.rotation.y, 
		target_yaw, 
		delta * yaw_lerp
	)
	
	# Vertical rotation
	pitch_pivot.rotation.x = lerp_angle(
		pitch_pivot.rotation.x, 
		0.0, 
		delta * pitch_lerp
	)

func _process_unlocked(_delta: float) -> void:
	# Rotation
	yaw_pivot.rotate_y(mouse_input.x * move_direction.x)
	pitch_pivot.rotate_x(mouse_input.y * move_direction.y)
	
	# Clamp and reset
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	mouse_delta = Vector2.ZERO

# ===
# Event Handlers
# ===

func _handle_world_player_spawned(_event: WorldEvent.PlayerSpawned) -> void:
	follow_target = Session.player_context.boat_instance

func _handle_camera_shake(event: WorldEvent.CameraShake) -> void:
	shake_intensity = event.intensity
	shake_duration = event.duration
