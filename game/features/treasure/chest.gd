class_name TreasureChest
extends BuoyantRigidBody

@export var type: Enums.ChestType = Enums.ChestType.WOOD

@onready var interaction_area: Area3D = $InteractionArea
@onready var animation_player: AnimationPlayer = $MeshInstance3D/AnimationPlayer

var _collected: bool = false

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

func _collect() -> void:
	var roll = randf()
	var cumulative_prob = 0.0
	
	var data: ChestData = Constants.LUT.get_chest_data(type)
	var table = data.rarity_drop_table
	var reward_data: ChestRewardData
	var gold_amount: int = 0
	
	for rarity in Enums.RarityType.values():
		cumulative_prob += table[rarity] 
		
		if roll <= cumulative_prob:
			reward_data = Constants.LUT.get_chest_reward_data(rarity)
			gold_amount = randi_range(reward_data.min_gold, reward_data.max_gold)
			break

	# Update Gold
	Context.progression.gold += gold_amount
	
	# Emit Event for UI/Sound
	EventBus.emit(
		WorldEvent.ChestCollected.new(
			reward_data.rarity,
			reward_data.name,
			reward_data.color,
			gold_amount
		)
	)

	print_debug("Chest collected! Type: %s, Rarity: %s, Gold: %d" % [
		Enums.ChestType.keys()[type], 
		reward_data.name, 
		gold_amount
	])

# ===
# Signals
# ===

func _on_body_entered(body: Node3D) -> void:
	if not _collected and body is Boat:
		_collected = true
		# Play animation
		animation_player.play("open")
		animation_player.animation_finished.connect(
			func (_anim_name):
				queue_free(),
			CONNECT_ONE_SHOT
		)
		
		# Fallback: If animation_finished doesn't fire for some reason
		get_tree().create_timer(2.0).timeout.connect(queue_free)
		
		_collect()
