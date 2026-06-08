extends CharacterBody3D


const SPEED = 5.0
const SLOW_FLY_SPEED = 8.0
const FLY_SPEED = 20.0
const JUMP_VELOCITY = 4.5

#signal add_block(pos: Vector3)
#signal remove_block(pos: Vector3)

@export var mouse_sens: float = 0.003

@onready var head: Node3D = $Head
@onready var eye_camera: Camera3D = $Head/EyeCamera
@onready var ray_cast: VoxelEngineBlockRay = %BlockRay

var free: bool = false
var flying: bool = true

func _ready() -> void:
	_update_mouse_mode()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dev_fly"):
		flying = not flying
	
	# Add the gravity.
	if not is_on_floor():
		if flying:
			velocity = Vector3.ZERO
		else:
			velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction := (eye_camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if flying:
			velocity = direction * FLY_SPEED
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if free: return
		
		var relative = event.relative * mouse_sens
		head.rotate_y(-relative.x)
		eye_camera.rotate_x(-relative.y)
		eye_camera.rotation.x = clamp(eye_camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))
	
	if Input.is_action_just_pressed("ui_cancel"):
		free = not free
		_update_mouse_mode()
	
	#if Input.is_action_just_pressed("add_block"):
		#var hit: BlockRay.RayHit = ray_cast.get_ray_hit()
		#if hit:
			#add_block.emit(hit.add_position)
	#
	#if Input.is_action_just_pressed("remove_block"):
		#var hit: BlockRay.RayHit = ray_cast.get_ray_hit()
		#if hit:
			#remove_block.emit(hit.remove_position)
	
func _update_mouse_mode() -> void:
	if free:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
