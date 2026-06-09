extends CharacterBody3D

const SPEED = 5.0
const FLY_SPEED = 20.0
const JUMP_VELOCITY = 4.5

@export var mouse_sens: float = 0.003
@export var chunk_manager: VoxelEngineChunkManager

@onready var head: Node3D = $Head
@onready var eye_camera: Camera3D = $Head/EyeCamera

var free: bool = false
var flying: bool = true

func _ready() -> void:
	_update_mouse_mode()
	await get_tree().process_frame
	if chunk_manager:
		chunk_manager.generate(0)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dev_fly"):
		flying = not flying
	
	if not is_on_floor():
		if flying:
			velocity = Vector3.ZERO
		else:
			velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction := (eye_camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var speed = FLY_SPEED if flying else SPEED
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if flying: velocity.y = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

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

func _update_mouse_mode() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if free else Input.MOUSE_MODE_CAPTURED
