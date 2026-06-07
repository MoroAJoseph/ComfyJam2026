class_name ChestData
extends RefCounted

var type: Enums.ChestType
var name: String
var color: Color
var rarity_drop_table: Dictionary[Enums.RarityType, float] = {}

func _init(
	p_type: Enums.ChestType, 
	p_color: Color, 
	p_rarity_drop_table: Dictionary[Enums.RarityType, float]
):
	type = p_type
	name = Enums.ChestType.keys()[p_type].capitalize()
	color = p_color
	rarity_drop_table = p_rarity_drop_table
