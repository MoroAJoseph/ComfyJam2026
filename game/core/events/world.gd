class_name WorldEvent
extends Event

class CameraShake extends WorldEvent:
	
	var intensity: float
	var duration: float
	
	func _init(
		p_intensity: float = 0.5, 
		p_duration: float = 0.3
	) -> void:
		intensity = p_intensity
		duration = p_duration

class GenerateLand extends WorldEvent: pass
class LandGenerated extends WorldEvent: pass

# --- Block ---
class BlockDestroyed extends WorldEvent:
	
	var type: Enums.BlockType
	var world_location: Vector3i
	
	func _init(
		p_type: Enums.BlockType, 
		p_world_location: Vector3i
	) -> void:
		type = p_type
		world_location = p_world_location

class BlockCollected extends WorldEvent:
	
	var item_data: BlockItemData
	
	func _init(
		p_item_data: BlockItemData
	) -> void:
		item_data = p_item_data

class SpawnBlockItem extends WorldEvent:
	
	var item_data: BlockItemData
	var world_location: Vector3
	
	func _init(
		p_item_data: BlockItemData, 
		p_world_location: Vector3
	) -> void:
		item_data = p_item_data
		world_location = p_world_location

# --- Player ---
class SpawnPlayer extends WorldEvent:
	
	var world_location: Vector3
	var rotation: Vector3
	
	func _init(
		p_world_location: Vector3, 
		p_rotation: Vector3
	) -> void:
		world_location = p_world_location
		rotation = p_rotation

class PlayerSpawned extends WorldEvent: 
	
	var player: Player
	
	func _init(
		p_player: Player
	) -> void:
		player = p_player

#class PlayerCollect extends WorldEvent:
	#
	#var block_instance_data: BlockInstanceData
	#var collect_strength: int
	#
	#func _init(
		#p_block_instance_data: BlockInstanceData,
		#p_collect_strength: int
	#) -> void:
		#block_instance_data = p_block_instance_data
		#collect_strength = p_collect_strength

#class PlayerDroppedBlockItem extends WorldEvent:
	#
	#var block_item_data: BlockItemData
	#var world_location: Vector3
	#
	#func _init(
		#p_block_item_data: BlockItemData, 
		#p_world_location: Vector3
	#) -> void:
		#block_item_data = p_block_item_data
		#world_location = p_world_location

# --- Interaction ---
class DockEntered extends WorldEvent: pass
class DockExited extends WorldEvent: pass

class ChestCollected extends WorldEvent:
	
	var rarity: Enums.RarityType
	var rarity_name: String
	var color: Color
	var gold_amount: int
	
	func _init(
		p_rarity: Enums.RarityType,
		p_rarity_name: String,
		p_color: Color,
		p_gold_amount: int,
	) -> void:
		rarity = p_rarity
		rarity_name = p_rarity_name
		color = p_color
		gold_amount = p_gold_amount
