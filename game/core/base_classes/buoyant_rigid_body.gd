class_name BuoyantRigidBody
extends RigidBody3D

@export_category("Buoyancy")

## Magnitude of the upward force. Higher = sits higher; Lower = sits lower (risk of sinking).
@export var float_force := 1.0

## Resistance to forward movement. Higher = slower top speed; Lower = longer coasting.
@export var water_drag_forward := 0.05

## Resistance to sliding/drifting. High values prevent sliding during turns.
@export var water_drag_sideways := 0.5

## Resistance to rotation. Higher values make the boat feel heavy/stable; Lower makes it spin easily.
@export var water_angular_drag := 0.1

@export_category("Stability")

## The force that pulls the boat back upright. Higher = harder to capsize.
@export var alignment_strength := 10.0

## Braking force for rotation. Higher = settles quickly; Lower = rocks/oscillates.
@export var alignment_damping := 0.5

@export_category("Air Physics")

## Gravity multiplier when not in water.
@export var air_gravity_scale := 3.0

## Resistance to movement in the air. Higher = slows down faster in mid-air.
@export var air_drag := 0.4

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var probes: Array[Node] = $Probes.get_children()

var submerged := false
var submersion_ratio := 0.0

var _pending_external_impulse := Vector3.ZERO

# ===
# Built-In
# ===

func _physics_process(_delta):
	_apply_buoyancy()
	
	# Apply more gravity and drag in air
	if not submerged:
		gravity_scale = air_gravity_scale
		linear_damp = air_drag
		angular_damp = air_drag
	else:
		gravity_scale = 1.0
		# Reset damping to allow the water logic to handle it via _integrate_forces
		linear_damp = 0.0
		angular_damp = 0.0

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		# Directional Drag (Keel Effect)
		# We resist sideways movement much more than forward movement
		var local_vel = global_transform.basis.inverse() * state.linear_velocity
		
		# Apply drag factor based on submersion
		var drag_factor = submersion_ratio
		
		local_vel.x *= (1.0 - water_drag_sideways * drag_factor)
		local_vel.z *= (1.0 - water_drag_forward * drag_factor)
		local_vel.y *= (1.0 - water_drag_sideways * drag_factor) # Vertical drag
		
		state.linear_velocity = global_transform.basis * local_vel
		
		# Angular Damping
		state.angular_velocity *= (1.0 - water_angular_drag * drag_factor)
		
		# Alignment Torque (Stability)
		# This pushes the boat to stay upright
		var current_up = global_transform.basis.y
		var target_up = Vector3.UP
		
		var torque = current_up.cross(target_up) * alignment_strength * drag_factor
		state.apply_torque(torque)
		
		# Add some damping to the alignment so it doesn't oscillate forever
		state.angular_velocity *= (1.0 - alignment_damping * drag_factor)

	# Apply external impulses that were registered
	if _pending_external_impulse != Vector3.ZERO:
		state.apply_central_impulse(_pending_external_impulse)
		_pending_external_impulse = Vector3.ZERO

# ===
# Public
# ===

func apply_external_impulse(impulse: Vector3) -> void:
	_pending_external_impulse += impulse

# ===
# Private
# ===

func _apply_buoyancy() -> void:
	submerged = false
	var submerged_count = 0
	
	for p in probes:
		var depth = Session.world_provider.get_sea_height(p.global_position) - p.global_position.y 
		if depth > 0:
			submerged = true
			submerged_count += 1
			
			var multiplier = _get_buoyancy_multiplier(p)
			
			# Apply upward force at probe position
			apply_force(
				Vector3.UP * float_force * gravity * depth * multiplier, 
				p.global_position - global_position
			)
	
	submersion_ratio = float(submerged_count) / float(probes.size()) if probes.size() > 0 else 0.0

func _get_buoyancy_multiplier(_probe: Node) -> float:
	return 1.0
