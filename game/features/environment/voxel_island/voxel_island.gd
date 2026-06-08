class_name VoxelIsland
extends Node3D

## Procedural Island Generator using the Hexagon Voxel Engine.

@export_group("Dimensions")
@export var radius_blocks: int = 10
@export var height_max: int = 4

@export_group("Noise")
@export var noise_frequency: float = 0.1
@export var noise_cutoff: float = 0.2

@export_group("Colors")
@export var color_sand: Color = Color(0.9, 0.8, 0.6)
@export var color_grass: Color = Color(0.55, 0.85, 0.3)
@export var color_stone: Color = Color(0.5, 0.5, 0.5)

@export_group("Assets")
@export var palm_tree_scene: PackedScene = preload("res://assets/environment/glb/palm-straight.glb")
@export var rock_scene: PackedScene = preload("res://assets/environment/glb/rocks-a.glb")
@export var chest_scene: PackedScene = preload("res://features/treasure/chest.tscn")
@export var grass_scene: PackedScene = preload("res://assets/environment/stylized_grass/grass.glb")
@export var grass_material: Material = preload("res://assets/environment/stylized_grass/grass_material.tres")

@onready var hexagon_mesh: VoxelEngineSurfaceCullingHexagonMesh = $Hexagon
@onready var grass_multimesh: MultiMeshInstance3D = $GrassMultiMesh

var hexagon_data: Dictionary[Vector3, Color] = {}

# Hexagon Constants from voxel engine
const RADIUS = 1.0
const APOTHEM = 0.866025
const X_SPACING = APOTHEM * 2.0
const Z_SPACING = 1.5

func _ready() -> void:
	_setup_grass_multimesh()
	generate_island()

func _setup_grass_multimesh() -> void:
	if not grass_multimesh:
		return
	
	if not grass_multimesh.multimesh:
		grass_multimesh.multimesh = MultiMesh.new()
	
	grass_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	
	# Extract mesh from the GLB scene
	if grass_scene:
		var temp_instance = grass_scene.instantiate()
		if temp_instance is MeshInstance3D:
			grass_multimesh.multimesh.mesh = temp_instance.mesh
		else:
			# If it's a Node3D with a MeshInstance child
			for child in temp_instance.get_children():
				if child is MeshInstance3D:
					grass_multimesh.multimesh.mesh = child.mesh
					break
		temp_instance.queue_free()
		
	grass_multimesh.material_override = grass_material

func generate_island() -> void:
	hexagon_data.clear()
	
	var hexagon_data: Dictionary[Vector3i, Color] = {}

	# Hexagon Constants from voxel engine
	const RADIUS = 1.0
	...

		# Generate grid within a circular range
		for x in range(-radius_blocks, radius_blocks + 1):
			for z in range(-radius_blocks, radius_blocks + 1):
				# Radial falloff
				var dist = sqrt(x*x + z*z)
				var falloff = 1.0 - (dist / float(radius_blocks))

				if falloff <= 0: continue

				# Calculate world position for asset placement using the new grid math
				var size = 1.0
				var h_const = 1.0
				var world_x = size * (3.0 / 2.0 * x)
				var world_z = size * (sqrt(3.0) / 2.0 * x + sqrt(3.0) * z)

				# Determine height
				var noise_val = (noise.get_noise_2d(x, z) + 1.0) / 2.0 # 0.0 to 1.0
				var current_height = int(falloff * height_max * noise_val)

				if current_height < 0: continue

				for y in range(current_height + 1):
					var grid_pos = Vector3i(x, y, z)
					var world_pos = Vector3(world_x, y * h_const, world_z)
					var color = _get_color_for_height(y, current_height)
					hexagon_data.set(grid_pos, color)

					# Add grass on top of grass blocks
					if y == current_height and color == color_grass:
						for i in range(8): # High density for a carpet look
							var offset = Vector3(randf_range(-0.6, 0.6), 0.5, randf_range(-0.6, 0.6))
							var grass_pos = world_pos + offset
							var basis = Basis().rotated(Vector3.UP, randf() * PI * 2.0)
							# Very low height (0.125) for a "short grass" look
							basis = basis.scaled(Vector3(randf_range(0.7, 1.3), 0.125, randf_range(0.7, 1.3)))
							grass_transforms.append(Transform3D(basis, grass_pos))

				# Spawn assets on the top block
				if current_height >= 0 and randf() < 0.1:
					_spawn_asset(Vector3(world_x, current_height + 0.5, world_z))

		hexagon_mesh.generate_mesh(hexagon_data)

	_update_grass_multimesh(grass_transforms)

func _update_grass_multimesh(transforms: Array[Transform3D]) -> void:
	if not grass_multimesh or transforms.is_empty():
		return
		
	grass_multimesh.multimesh.instance_count = 0 # Clear previous
	grass_multimesh.multimesh.instance_count = transforms.size()
	for i in range(transforms.size()):
		grass_multimesh.multimesh.set_instance_transform(i, transforms[i])

func _get_color_for_height(y: int, max_y: int) -> Color:
	if y == 0: return color_sand
	if y < height_max - 1: return color_grass
	return color_stone

func _spawn_asset(pos: Vector3) -> void:
	# Only spawn on top surface
	var asset_scene = palm_tree_scene if randf() > 0.4 else rock_scene
	if not asset_scene: return
	
	var instance = asset_scene.instantiate()
	add_child(instance)
	# Position slightly above center of block
	instance.position = pos + Vector3(0, 0.5, 0)
	instance.rotation.y = randf() * PI * 2.0
	instance.scale = Vector3.ONE * randf_range(0.8, 1.4)
