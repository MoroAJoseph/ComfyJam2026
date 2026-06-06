class_name WorldEvent
extends Event


# --- Block ---
class BlockDestroyed extends WorldEvent:
	
	var block_instance_data: BlockInstanceData
	
	func _init(
		p_block_instance_data: BlockInstanceData, 
	) -> void:
		block_instance_data = p_block_instance_data

class BlockHoverUpdated extends WorldEvent:
	
	var is_hovered: bool
	var block_instance_data: BlockInstanceData
	
	func _init(
		p_is_hovered: bool, 
		p_block_instance_data: BlockInstanceData,
	) -> void:
		is_hovered = p_is_hovered
		block_instance_data = p_block_instance_data

# --- Block Item ---
class BlockItemCollected extends WorldEvent:
	
	var item_data: BlockItemData
	
	func _init(
		p_item_data: BlockItemData
	) -> void:
		item_data = p_item_data

# --- Player ---
class PlayerSpawned extends WorldEvent: 
	
	var player: Player
	
	func _init(
		p_player: Player
	) -> void:
		player = p_player

class PlayerCollect extends WorldEvent:
	
	var block_instance_data: BlockInstanceData
	var collect_strength: int
	
	func _init(
		p_block_instance_data: BlockInstanceData,
		p_collect_strength: int
	) -> void:
		block_instance_data = p_block_instance_data
		collect_strength = p_collect_strength

class PlayerDroppedBlockItem extends WorldEvent:
	
	var block_item_data: BlockItemData
	var world_location: Vector3
	
	func _init(
		p_block_item_data: BlockItemData, 
		p_world_location: Vector3
	) -> void:
		block_item_data = p_block_item_data
		world_location = p_world_location
