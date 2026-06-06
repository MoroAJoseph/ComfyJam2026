class_name Player
extends BuoyantRigidBody


var context: PlayerContext
var progression_context: ProgressionContext

# ===
# Built-In
# ===

func _ready() -> void:
	context = Context.player
	context.instance = self
	progression_context = Context.progression
	
	_update_boat()

func _physics_process(_delta: float) -> void:
	var turn = Input.get_axis("player_left", "player_right")
	var move = Input.get_axis("player_forward", "player_backward")
	
	if current_boat:
		current_boat.set_input(turn, move)
		context.world_location = current_boat.global_position
		context.boat_direction = current_boat.get_direction()

# ===
# Public
# ===

# ===
# Private
# ===

func _update_boat() -> void:
	if not data: return
	
	if (
		Constants.LUT.BOAT_SCENE_PATH.has(data.current_boat_type) and 
		Constants.LUT.BOAT_DATA.has(data.current_boat_type)
	):
		var boat_scene_path: String = Constants.LUT.BOAT_SCENE_PATH.get(data.current_boat_type)
		var boat_data: BoatData = Constants.LUT.BOAT_DATA.get(data.current_boat_type)
		var boat_scene: PackedScene = load(boat_scene_path)
		var boat: Boat = boat_scene.instantiate()
		boat.data = boat_data
		boat_container.add_child(boat)
		boat.item_collector_remote_transform_3d.remote_path = item_collection_area.get_path()
		current_boat = boat
		camera.target_boat = boat
		# TODO update camera max and min zoom based on boat data

func _can_collect_block() -> bool:
	if not hovered_block: return false
	
	var block_data := Constants.LUT.get_block_data(hovered_block.type)
	if not block_data: return false
	
	# Strength
	if block_data.required_strength > data.collect_strength: return false
	
	# Distance
	var origin := current_boat.global_position
	var dx := origin.x - hovered_block.global_position.x
	var dz := origin.z - hovered_block.global_position.z
	var dist_sq := dx * dx + dz * dz
	var radius := data.collection_radius + 0.1

	return dist_sq <= radius * radius

func _drop_items_at_location(items: Array[BlockItemData], location: Vector3) -> void:
	for item in items:
		EventBus.emit(
			GameEvent.PlayerDroppedBlockItem.new(
				item, 
				location
			)
		)

# ===
# Signals
# ===

func _on_item_collection_area_area_entered(area: Area3D) -> void:
	if not current_boat: return
	
	var parent = area.get_parent()
	if parent is BlockItem:
		var inventory: InventoryContext = context.inventory
		inventory.capacity = current_boat.data.carry_weight_cap
		
		var item_data = parent.data
		
		# 1. Attempt to add the item (The logic inside add_item handles the splitting)
		# Note: add_item modifies item_data.stack_count internally.
		if inventory.add_item(item_data):
			# If stack_count is now 0, the whole item was picked up
			if item_data.stack_count <= 0:
				parent.queue_free()
			else:
				# If stack_count > 0, it means some couldn't fit. 
				# Spawn the remainder into the world.
				EventBus.emit(
					GameEvent.PlayerDroppedBlockItem.new(
						item_data, 
						parent.global_position
					)
				)
				# CRITICAL: if we are saving here, the block data vanishes from the world. 
				parent.queue_free()
		else:
			print_debug("Inventory completely full!")

func _handle_game_event_block_hover_updated(event: GameEvent.BlockHoverUpdated) -> void:
	hovered_block = event.block_instance_data if event.is_hovered else null
