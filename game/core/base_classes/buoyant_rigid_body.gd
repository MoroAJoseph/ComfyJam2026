class_name BuoyantRigidBody
extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.1
@export var water_angular_drag := 0.2
@export var alignment_strength := 10.0
@export var angular_damping := 5.0

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var probes: Array[Node] = $Probes.get_children()

var world_context: WorldContext
var submerged := false

# ===
# Built-In
# ===

func _ready() -> void:
	world_context = Context.world
	#axis_lock_angular_x = true
	#axis_lock_angular_z = true

func _physics_process(_delta):
	_apply_buoyancy()

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *= (1.0 - water_drag)
		state.angular_velocity.x *= (1.0 - water_angular_drag)
		state.angular_velocity.z *= (1.0 - water_angular_drag)

# ===
# Private
# ===

func _apply_buoyancy() -> void:
	submerged = false
	for p in probes:
		var depth = world_context.get_sea_height(p.global_position) - p.global_position.y 
		if depth > 0:
			submerged = true
			apply_force(
				Vector3.UP * float_force * gravity * depth, 
				p.global_position - global_position
			)
