class_name TreasureChest
extends BuoyantRigidBody

@export var type: Enums.ChestType = Enums.ChestType.WOOD

@onready var interaction_area: Area3D = $InteractionArea
@onready var animation_player: AnimationPlayer = $MeshInstance3D/AnimationPlayer

# ===
# Built-In
# ===

func _ready() -> void:
	super._ready()
	interaction_area.body_entered.connect(_on_body_entered)
	_setup_visuals()

# ===
# Private
# ===

func _setup_visuals() -> void:
	var data = Constants.LUT.CHEST_DATA[type]
	
	# 1. Tint the Chest itself
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
		material.albedo_color = data.color
		if type != Enums.ChestType.WOOD:
			material.metallic = 0.5
			material.roughness = 0.2
		mesh_instance.set_surface_override_material(0, material)
	
	# 2. Setup the Indicator Cube
	var indicator: MeshInstance3D = get_node_or_null("IndicatorCube")
	if indicator:
		var indicator_material = StandardMaterial3D.new()
		indicator_material.albedo_color = data.color
		indicator_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED # Make it "glow"
		indicator.set_surface_override_material(0, indicator_material)
		
		# Add a little bobbing animation
		var tween = create_tween().set_loops()
		tween.tween_property(indicator, "position:y", 1.4, 1.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(indicator, "position:y", 1.2, 1.0).set_trans(Tween.TRANS_SINE)
		
		var rot_tween = create_tween().set_loops()
		rot_tween.tween_property(indicator, "rotation:y", PI * 2, 2.0).as_relative()

# ===
# Signals
# ===

func _on_body_entered(body: Node3D) -> void:
	if body is Boat:
		var reward = Constants.LUT.get_random_chest_reward(type)
		# Play animatio
		animation_player.play("open")
		animation_player.animation_finished.connect(
			func ():
				queue_free()
		)
		
		# Update Gold
		Context.progression.gold += reward.gold
		
		# Emit Event for UI/Sound
		EventBus.emit(
			WorldEvent.ChestCollected.new(
				# pass the chest data
				reward.rarity,
				reward.name,
				reward.gold,
				reward.color
			)
		)
		
		print_debug("Chest collected! Type: %s, Rarity: %s, Gold: %d" % [
			Enums.ChestType.keys()[type], 
			reward.name, 
			reward.gold
		])
