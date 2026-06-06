class_name WorldContext
extends RefCounted

var time: float
var sea_time: float
var sea_instance: WorldSea

func get_sea_height(from_position: Vector3) -> float:
	if sea_instance:
		return sea_instance.get_height(from_position, sea_time)
	else:
		push_error("No sea instance")
		return 0.0
