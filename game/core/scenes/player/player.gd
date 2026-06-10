class_name Player
extends Node3D


# ===
# Built-In
# ===
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("action_collect"):
		#if _can_collect_block():
			#EventBus.emit(
				#GameEvent.PlayerCollect.new(
					#hovered_block,
					#data.collect_strength
				#)
			#)

# ===
# Public
# ===

# ===
# Private
# ===

#func _can_collect_block() -> bool:
	#if not hovered_block: return false
	#
	#var block_data := Constants.LUT.get_block_data(hovered_block.type)
	#if not block_data: return false
	#
	## Strength
	#if block_data.required_strength > data.collect_strength: return false
	#
	## Distance
	#var origin := current_boat.global_position
	#var dx := origin.x - hovered_block.global_position.x
	#var dz := origin.z - hovered_block.global_position.z
	#var dist_sq := dx * dx + dz * dz
	#var radius := data.collection_radius + 0.1
#
	#return dist_sq <= radius * radius

#func _drop_items_at_location(items: Array[BlockItemData], location: Vector3) -> void:
	#for item in items:
		#EventBus.emit(
			#GameEvent.PlayerDroppedBlockItem.new(
				#item, 
				#location
			#)
		#)

# ===
# Signals
# ===

#func _on_item_collection_area_entered(area: Area3D) -> void:
	#if not current_boat: return
	#
	#var parent = area.get_parent()
	#if parent is BlockItem:
		#var inventory: InventoryContext = context.inventory
		#inventory.capacity = current_boat.data.carry_weight_cap
		#
		#var item_data = parent.data
		#
		## Attempt to add the item
		#if inventory.add_item(item_data):
			## If stack_count is now 0, the whole item was picked up
			#if item_data.stack_count <= 0:
				#parent.queue_free()
			#else:
				## If stack_count > 0, it means some couldn't fit. 
				## Spawn the remainder into the world.
				#EventBus.emit(
					#GameEvent.PlayerDroppedBlockItem.new(
						#item_data, 
						#parent.global_position
					#)
				#)
				## CRITICAL: if we are saving here, the block data vanishes from the world. 
				#parent.queue_free()
		#else:
			#print_debug("Inventory completely full!")
