class_name WorldTimeController
extends Node

@export var time: float = 0.0
@export var max_time: float = 1.0 * 60 * 60 * 24  # 24 hours
@export var scale: float = 1.0 * 60 * 24 # 1-Minute cycles

var world_context: WorldContext

func _ready() -> void:
	world_context = Context.world

func _process(delta: float) -> void:
	# Ensure max_time is never zero to avoid division by infinity
	if max_time <= 0.0:
		push_error("WorldTimeController: max_time must be greater than 0!")
		return
		
	time = fmod(time + (delta * scale) / max_time, 1.0)
	
	# Safety check for the value being sent to the provider
	if is_finite(time):
		world_context.time = time
