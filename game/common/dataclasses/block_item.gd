class_name BlockItemData
extends Resource

var type: Enums.BlockType
var stack_count: int = 1
var block_data: BlockData

var max_stack: int:
	get:
		var block_data: BlockData = AssetService.get_block_data(type)
		return block_data.max_stack if block_data else 0

var color: Color:
	get: return block_data.color

var texture: Texture2D:
	get: return block_data.texture
var total_value: int:
	get:
		return block_data.value * stack_count if block_data else 0

func _init(
	p_type: Enums.BlockType, 
	p_stack_count: int
) -> void:
	type = p_type
	stack_count = p_stack_count
	block_data = AssetService.get_block_data(p_type)
