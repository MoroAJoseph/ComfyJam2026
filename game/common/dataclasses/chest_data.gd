class_name ChestData
extends Resource

@export var type: Enums.ChestType
@export var display_name: String
@export var color: Color
@export var rarity_drop_table: Dictionary[Enums.RarityType, float] = {
	Enums.RarityType.COMMON: 0.0,
	Enums.RarityType.EPIC: 0.0,
	Enums.RarityType.RARE: 0.0,
	Enums.RarityType.LEGENDARY: 0.0,
}
