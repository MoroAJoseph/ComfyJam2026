@tool
class_name UIUpgradesOwnedHeader
extends MarginContainer

@onready var current_owned_count: Label = %CurrentOwnedCount
@onready var total_ownable_count: Label = %TotalOwnableCount

func set_counts(current: int, total: int) -> void:
	if current_owned_count: current_owned_count.text = str(current)
	if total_ownable_count: total_ownable_count.text = str(total)
