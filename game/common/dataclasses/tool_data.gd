class_name ToolData
extends  RefCounted

var type: Enums.ToolType
var name: String
var strength: int
var speed: float
var range: float

func _init(
	p_type: Enums.ToolType, 
	p_strength: int, 
	p_speed: float, 
	p_range: float
) -> void:
	type = p_type
	name = Enums.ToolType.keys()[p_type].capitalize()
	strength = p_strength
	speed = p_speed
	range = p_range
