class_name Dock
extends StaticBody3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var glow_ring: MeshInstance3D = $InteractionArea/GlowRing

# ===
# Built-In
# ===

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	
	_setup_glow_ring_animation()

# ===
# Private
# ===

func _setup_glow_ring_animation() -> void:
	# Make material unique for this instance to avoid affecting other docks
	var material: StandardMaterial3D = glow_ring.mesh.material.duplicate()
	glow_ring.set_surface_override_material(0, material)
	
	# Ensure it's always visible
	material.no_depth_test = true
	material.render_priority = 1 # Draw after most things
	
	var tween = create_tween().set_loops()
	
	# Pulse scale
	tween.tween_property(glow_ring, "scale", Vector3(1.1, 1.1, 1.1), 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(glow_ring, "scale", Vector3(1.0, 1.0, 1.0), 2.0).set_trans(Tween.TRANS_SINE)
	
	# Pulse alpha
	tween.parallel().tween_property(material, "albedo_color:a", 0.6, 2.0).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(material, "albedo_color:a", 0.2, 2.0).set_trans(Tween.TRANS_SINE)
	
	# Constant rotation
	var rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(glow_ring, "rotation:y", PI * 2, 10.0).as_relative()

# ===
# Signals
# ===

func _on_body_entered(body: Node3D) -> void:
	if body is Boat:
		EventBus.emit(WorldEvent.DockEntered.new())

func _on_body_exited(body: Node3D) -> void:
	if body is Boat:
		EventBus.emit(WorldEvent.DockExited.new())
