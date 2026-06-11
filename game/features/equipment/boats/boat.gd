class_name Boat
extends BuoyantRigidBody

# TODO: Make the front of the boat have more force when floating, so the front tilts down into the wave its riding

@export var data: BoatData

@onready var model = $Model

var _turn_input: float = 0.0
var _move_input: float = 0.0
var _collision_slow := 0.0

# ===
# Built-In
# ===

func _physics_process(delta: float) -> void:
	if not data: return
	_apply_buoyancy()
	_apply_rotation(delta)
	_apply_movement(delta)
	_clamp_collision_slide(delta)

# ===
# Public
# ===

func set_input(turn: float, move: float):
	_turn_input = turn
	_move_input = move

func get_direction() -> Vector3:
	return -model.global_transform.basis.z.normalized()

func get_collision_speed_multiplier() -> float:
	return 1.0 - (_collision_slow * 0.3)

# ===
# Private
# ===

func _apply_rotation(delta: float) -> void:
	# Determine direction modifier: 1.0 for forward, -1.0 for backward
	# We use sign() to get -1, 0, or 1. Default to 1 if stationary.
	var direction_mod = sign(_move_input) if _move_input != 0 else 1.0
	
	# Apply modifier to the turn velocity
	var target_turn_velocity = -_turn_input * data.turn_speed * submersion_ratio * direction_mod
	
	# Smoothly interpolate angular velocity to the target
	angular_velocity.y = lerp(
		angular_velocity.y, 
		target_turn_velocity, 
		data.angular_drag * delta * 5.0
	)

	# Handle banking animation (Optional: reverse bank direction when moving backward)
	var target_bank: float = _turn_input * 0.25 * submersion_ratio * direction_mod
	model.rotation.z = lerp(
		model.rotation.z, 
		-target_bank, 
		delta * 3.0
	)


func _apply_movement(delta: float) -> void:
	# Only allow forward movement when in the water
	if not submerged:
		return
	
	# Get forward
	var forward_dir = -global_transform.basis.z
	var desired = forward_dir * _move_input * data.max_speed
	
	var current_horizontal := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	var steer = (desired - current_horizontal) * data.acceleration
	
	# Apply force scaled by submersion_ratio. 
	# If submersion_ratio is 0 (in air), no propulsion is applied.
	apply_force(steer * submersion_ratio, Vector3.ZERO)

	# Visual pitch
	var target_pitch := -_move_input * 0.15 * submersion_ratio
	model.rotation.x = lerp(model.rotation.x, target_pitch, delta * 3.0)

func _clamp_collision_slide(delta: float) -> void:
	var v := linear_velocity
	var y := v.y

	var horizontal := Vector3(v.x, 0, v.z)

	if horizontal.length() < 0.01:
		return

	# Try to detect if we're pushing into something
	var space_state := get_world_3d().direct_space_state

	var forward := global_transform.basis.z.normalized()
	var origin := global_position + Vector3.UP * 0.5

	var query := PhysicsRayQueryParameters3D.create(
		origin,
		origin + forward * 1.5
	)

	query.collision_mask = Constants.PhysicsLayer.LAND_MASK | Constants.PhysicsLayer.BARREL_MASK

	var hit := space_state.intersect_ray(query)

	if hit:
		var normal: Vector3 = hit.normal

		# PROJECT velocity onto surface → SLIDE instead of bounce
		horizontal = horizontal.slide(normal)

		# damp impact so you lose speed when hitting land
		horizontal *= (1.0 - data.collision_damping)

		_collision_slow = 1.0
	else:
		# decay collision penalty
		_collision_slow = lerp(_collision_slow, 0.0, delta * 2.0)

	# apply smoothing so physics doesn't jitter
	linear_velocity = Vector3(horizontal.x, y, horizontal.z)
# Signals
# ===
