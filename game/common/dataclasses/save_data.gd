class_name SaveData
extends Resource

@export var gold: int = 0

func update() -> void:
	gold = Context.player.gold

func apply() -> void:
	Context.player.gold = gold
