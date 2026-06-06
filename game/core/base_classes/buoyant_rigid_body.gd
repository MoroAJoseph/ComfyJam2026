class_name BuoyantRigidBody
extends RigidBody3D

@export_category("Buoyancy")
@export var float_force := 1.0
@export var water_drag_forward := 0.05
@export var water_drag_sideways := 0.5
@export var water_angular_drag := 0.1

@export_category("Stability")
@export var alignment_strength := 10.0
@export var alignment_damping := 0.5

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var probes: Array[Node] = $Probes.get_children()

var world_context: WorldContext
var submerged := false
var submersion_ratio := 0.0

# ===
# Built-In
# ===

func _ready() -> void:
	world_context = Context.world

func _physics_process(_delta):
	_apply_buoyancy()

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		# 1. Directional Drag (Keel Effect)
		# We resist sideways movement much more than forward movement
		var local_vel = global_transform.basis.inverse() * state.linear_velocity
		
		# Apply drag factor based on submersion
		var drag_factor = submersion_ratio
		
		local_vel.x *= (1.0 - water_drag_sideways * drag_factor)
		local_vel.z *= (1.0 - water_drag_forward * drag_factor)
		local_vel.y *= (1.0 - water_drag_sideways * drag_factor) # Vertical drag
		
		state.linear_velocity = global_transform.basis * local_vel
		
		# 2. Angular Damping
		state.angular_velocity *= (1.0 - water_angular_drag * drag_factor)
		
		# 3. Alignment Torque (Stability)
		# This pushes the boat to stay upright
		var current_up = global_transform.basis.y
		var target_up = Vector3.UP
		
		var torque = current_up.cross(target_up) * alignment_strength * drag_factor
		state.apply_torque(torque)
		
		# Add some damping to the alignment so it doesn't oscillate forever
		state.angular_velocity *= (1.0 - alignment_damping * drag_factor)

# ===
# Private
# ===

func _apply_buoyancy() -> void:
	submerged = false
	var submerged_count = 0
	
	for p in probes:
		var depth = world_context.get_sea_height(p.global_position) - p.global_position.y 
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
