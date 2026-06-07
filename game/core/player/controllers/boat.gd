class_name PlayerBoatController
extends Node3D

var current_boat: Boat = null
var progression_context: ProgressionContext
var player_context: PlayerContext

func _ready() -> void:
	progression_context = Context.progression
	player_context = Context.player
	
	progression_context.equipped_boat_type_updated.connect(spawn_boat)
	spawn_boat(progression_context.equipped_boat_type)

func _process(_delta: float) -> void:
	var turn = Input.get_axis("player_left", "player_right")
	var move = Input.get_axis("player_backward", "player_forward")
	
	if (
		player_context and 
		current_boat
	):
		current_boat.set_input(turn, move)
		player_context.boat_direction = current_boat.get_direction()
		player_context.world_location = current_boat.global_position
		print_debug("boat controller: ", player_context.world_location)
	
func spawn_boat(boat_type: BoatData.Type) -> void:
	# Cleanup
	for child in get_children():
		child.queue_free()
	
	var path: String = Constants.Paths.get_boat_scene(boat_type)
	var boat_data: BoatData = Constants.LUT.get_boat_data(boat_type)
	var boat: Boat = load(path).instantiate()
	boat.data = boat_data
	add_child(boat)
	current_boat = boat
	player_context.boat_instance = boat
