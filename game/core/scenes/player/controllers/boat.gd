class_name PlayerBoatController
extends Node3D

var current_boat: Boat = null

func _ready() -> void:
	Session.player_context.equipped_boat_updated.connect(spawn_boat)
	spawn_boat(Session.player_context.equipped_boat)

func _process(_delta: float) -> void:
	var turn = Input.get_axis("player_left", "player_right")
	var move = Input.get_axis("player_backward", "player_forward")
	
	if (
		current_boat
	):
		current_boat.set_input(turn, move)

func spawn_boat(boat_type: Enums.BoatType) -> void:
	# Cleanup
	for child in get_children():
		child.queue_free()
	
	var boat_data: BoatData = AssetService.get_boat_data(boat_type)
	var boat: Boat = AssetService.get_boat_scene(boat_type)
	boat.data = boat_data
	add_child(boat)
	current_boat = boat
	Session.player_provider.set_boat_instance(boat)
