class_name ExplodingBarrel
extends BuoyantRigidBody

@export var type: Enums.BarrelType = Enums.BarrelType.IRON

@onready var interaction_area: Area3D = $InteractionArea

var _triggered := false
var _data: BarrelData

# ===
# Built-In
# ===

func _ready() -> void:
	_data = AssetService.get_barrel_data(type)
	interaction_area.body_entered.connect(_on_body_entered)
	_setup_visuals()

# ===
# Private
# ===

func _setup_visuals() -> void:
	if not _data: return
	
	# 1. Tint the Barrel Mesh
	var mesh_instance: MeshInstance3D
	if $MeshInstance3D is MeshInstance3D:
		mesh_instance = $MeshInstance3D
	else:
		for child in $MeshInstance3D.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	
	if mesh_instance:
		var material = StandardMaterial3D.new()
		material.albedo_color = _data.color
		
		# Material properties based on type
		match type:
			Enums.BarrelType.WOOD:
				material.roughness = 0.8
				material.metallic = 0.0
			Enums.BarrelType.IRON:
				material.roughness = 0.3
				material.metallic = 0.5
			Enums.BarrelType.GOLD:
				material.roughness = 0.1
				material.metallic = 0.8
				
		mesh_instance.set_surface_override_material(0, material)

	# 2. Setup the Indicator
	var indicator: MeshInstance3D = get_node_or_null("Indicator")
	if indicator:
		var indicator_material = StandardMaterial3D.new()
		indicator_material.albedo_color = _data.color
		indicator_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED # Make it "glow"
		indicator.set_surface_override_material(0, indicator_material)
		
		# Add a little bobbing animation
		var tween = create_tween().set_loops()
		tween.tween_property(indicator, "position:y", 1.4, 1.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(indicator, "position:y", 1.2, 1.0).set_trans(Tween.TRANS_SINE)
		
		var rot_tween = create_tween().set_loops()
		rot_tween.tween_property(indicator, "rotation:y", PI * 2, 2.0).as_relative()

func _on_body_entered(body: Node3D) -> void:
	# Robust boat check
	if not _triggered and (body is Boat or body.has_method("set_input")):
		_triggered = true
		print_debug("[Barrel] Triggered by: ", body.name)
		explode(body)

func explode(target_body: RigidBody3D = null) -> void:
	if not _data: return
	
	# 1. Identify targets
	var boat = target_body if target_body else Session.player_context.boat_instance
	
	if boat:
		var dir = boat.global_position - global_position
		var distance = dir.length()
		
		# Calculate purely horizontal direction for the main force
		var horizontal_dir = Vector3(dir.x, 0, dir.z).normalized()
		if horizontal_dir.length() < 0.01:
			horizontal_dir = Vector3.MODEL_FRONT # Fallback
		
		if distance < _data.explosion_radius:
			var falloff = 1.0 - clamp(distance / _data.explosion_radius, 0.0, 1.0)
			
			# Main force is horizontal
			var final_force = horizontal_dir * _data.explosion_force * falloff
			# Upward force is strictly controlled by vertical_boost
			final_force.y = _data.vertical_boost * falloff
			
			print_debug("[Barrel] Applying impulse: ", final_force, " to ", boat.name)
			
			# Wake up the boat just in case
			if "sleeping" in boat:
				boat.sleeping = false
			
			# Apply linear knockback
			if boat.has_method("apply_external_impulse"):
				boat.apply_external_impulse(final_force)
			elif boat.has_method("apply_central_impulse"):
				boat.apply_central_impulse(final_force)
			
			# Apply some random torque to make it look chaotic
			if boat.has_method("apply_torque_impulse"):
				var random_torque = Vector3(
					randf_range(-1, 1),
					randf_range(-1, 1),
					randf_range(-1, 1)
				).normalized() * _data.torque_force * falloff
				boat.apply_torque_impulse(random_torque)
			
			# Camera Shake
			EventBus.emit(WorldEvent.CameraShake.new(1.5, 0.6))
	
	# 2. Visuals
	_spawn_explosion_particles()
	
	# 3. Cleanup
	visible = false
	$CollisionShape3D.set_deferred("disabled", true)
	interaction_area.set_deferred("monitoring", false)
	
	# We wait a frame to ensure physics is applied before freeing
	await get_tree().process_frame
	queue_free()

func _spawn_explosion_particles() -> void:
	var parent = get_parent()
	if not parent: return
	
	# Fire Burst
	var fire := CPUParticles3D.new()
	fire.amount = 80
	fire.one_shot = true
	fire.explosiveness = 1.0
	fire.lifetime = 0.8
	fire.mesh = SphereMesh.new()
	(fire.mesh as SphereMesh).radius = 0.4
	(fire.mesh as SphereMesh).height = 0.8
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color.ORANGE_RED
	mat.emission_enabled = true
	mat.emission = Color.ORANGE
	mat.emission_energy_multiplier = 5.0
	fire.material_override = mat
	
	fire.direction = Vector3.UP
	fire.spread = 180.0
	fire.gravity = Vector3.UP * 8.0
	fire.initial_velocity_min = 20.0
	fire.initial_velocity_max = 35.0
	
	var fire_curve = Curve.new()
	fire_curve.add_point(Vector2(0, 1))
	fire_curve.add_point(Vector2(1, 0))
	fire.scale_amount_curve = fire_curve
	
	parent.add_child(fire)
	fire.global_position = global_position
	fire.emitting = true
	
	# Thick Smoke
	var smoke := CPUParticles3D.new()
	smoke.amount = 50
	smoke.one_shot = true
	smoke.explosiveness = 0.95
	smoke.lifetime = 2.0
	smoke.mesh = SphereMesh.new()
	(smoke.mesh as SphereMesh).radius = 0.7
	(smoke.mesh as SphereMesh).height = 1.4
	
	var smoke_mat := StandardMaterial3D.new()
	smoke_mat.albedo_color = Color(0.1, 0.1, 0.1, 0.9)
	smoke_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smoke.material_override = smoke_mat
	
	smoke.direction = Vector3.UP
	smoke.spread = 90.0
	smoke.gravity = Vector3.UP * 2.0
	smoke.initial_velocity_min = 8.0
	smoke.initial_velocity_max = 15.0
	
	var smoke_curve = Curve.new()
	smoke_curve.add_point(Vector2(0, 0.5))
	smoke_curve.add_point(Vector2(0.2, 1.0))
	smoke_curve.add_point(Vector2(1, 0))
	smoke.scale_amount_curve = smoke_curve
	
	parent.add_child(smoke)
	smoke.global_position = global_position
	smoke.emitting = true

	# Cleanup particles
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(fire.queue_free)
	timer.timeout.connect(smoke.queue_free)

# ===
# Signals
# ===
