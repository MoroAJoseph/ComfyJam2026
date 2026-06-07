class_name ChestRewardData
extends RefCounted

var rarity: Enums.RarityType
var name: String
var min_gold: int
var max_gold: int
var color: Color

func _init(
	p_rarity: Enums.RarityType, 
	p_min_gold: int, 
	p_max_gold: int, 
	p_color: Color, 
):
	name = Enums.RarityType.keys()[p_rarity].capitalize()
	rarity = p_rarity
	min_gold = p_min_gold
	max_gold = p_max_gold
	color = p_color
