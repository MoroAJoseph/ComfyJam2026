extends CharacterBody3D

signal add_voxel()
signal remove_voxel()

@export var mouse_sens: float = 0.003
@export var ground_speed: float = 5.0
@export var fly_speed: float = 20.0
@export var jump_velocity: float = 4.5

@onready var head: Node3D = $Head
@onready var eye_camera: Camera3D = $Head/EyeCamera
@onready var block_modification: RayCast3D = $Head/EyeCamera/BlockModification

var free: bool = false
var flying: bool = true

func _ready() -> void:
	_update_mouse_mode()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dev_fly"):
		flying = not flying
	
	if not is_on_floor():
		if flying:
			velocity = Vector3.ZERO
		else:
			velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	 
	var input_dir := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction := (eye_camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var speed = fly_speed if flying else ground_speed
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if flying: velocity.y = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, ground_speed)
		velocity.z = move_toward(velocity.z, 0, ground_speed)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not free:
		var relative = event.relative * mouse_sens
		head.rotate_y(-relative.x)
		eye_camera.rotate_x(-relative.y)
		eye_camera.rotation.x = clamp(eye_camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if Input.is_action_just_pressed("ui_cancel"):
		free = not free
		_update_mouse_mode()
	
	# Speed Controls
	if Input.is_action_just_pressed("ui_up"):
		fly_speed += 2.0
	elif Input.is_action_just_pressed("ui_down"):
		fly_speed -= 2.0
	if Input.is_action_just_pressed("ui_right"):
		ground_speed += 1.0
	elif Input.is_action_just_pressed("ui_left"):
		ground_speed -= 1.0
	
	# Block Modifications
	if event.is_action_pressed("dev_add_block"):
		print_debug("add")
		var hit = block_modification.get_ray_hit()
		if !hit: return
		
		add_voxel.emit(hit.add_world_position, Enums.BlockType.GRASS)
		
	if event.is_action_pressed("dev_remove_block"):
		print_debug("remove")
		var hit = block_modification.get_ray_hit()
		if !hit: return
		
		remove_voxel.emit(hit.remove_world_position)

func _update_mouse_mode() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if free else Input.MOUSE_MODE_CAPTURED
