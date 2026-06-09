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
		Session.player_context.boat_direction = current_boat.get_direction()
		Session.player_context.world_location = current_boat.global_position
	
func spawn_boat(boat_type: Enums.BoatType) -> void:
	# Cleanup
	for child in get_children():
		child.queue_free()
	
	print_debug(boat_type)
	var boat_data: BoatData = AssetProvider.get_boat_data(boat_type)
	var boat: Boat = AssetProvider.get_boat_scene(boat_type)
	print_debug(boat_data, boat)
	boat.data = boat_data
	add_child(boat)
	current_boat = boat
	Session.player_context.boat_instance = boat
