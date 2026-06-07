class_name StarterIsland
extends Node3D

## A fixed, hand-crafted starting island using the Hexagon Voxel Engine.

@export_group("Assets")
@export var grass_scene: PackedScene = preload("res://assets/environment/stylized_grass/grass.glb")
@export var grass_material: Material = preload("res://assets/environment/stylized_grass/grass_material.tres")

@onready var hexagon_mesh: VoxelEngineSurfaceCullingHexagonMesh = $Hexagon
@onready var grass_multimesh: MultiMeshInstance3D = $GrassMultiMesh

# Hexagon Constants
const RADIUS = 1.0
const APOTHEM = 0.866025
const X_SPACING = APOTHEM * 2.0
const Z_SPACING = 1.5

const COLOR_SAND = Color(0.9, 0.8, 0.6)
const COLOR_GRASS = Color(0.55, 0.85, 0.3)
const COLOR_STONE = Color(0.5, 0.5, 0.5)

var hexagon_data: Dictionary[Vector3, Color] = {}
var grass_transforms: Array[Transform3D] = []

func _ready() -> void:
	_setup_grass_multimesh()
	generate_fixed_island()

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

func generate_island_block(x: int, z: int, height: int) -> void:
	var world_x = x * X_SPACING
	var world_z = z * Z_SPACING
	if z % 2 != 0:
		world_x += APOTHEM
		
	for y in range(height):
		var pos = Vector3(world_x, y, world_z)
		var color = COLOR_SAND # Sand
		if y > 0: color = COLOR_GRASS # Grass
		if y > 2: color = COLOR_STONE # Stone
		
		hexagon_data.set(pos, color)
		
		# Add grass on top of grass blocks
		if y == height - 1 and color == COLOR_GRASS:
			for i in range(8): # High density for a carpet look
				var offset = Vector3(randf_range(-0.6, 0.6), 0.5, randf_range(-0.6, 0.6))
				var grass_pos = pos + offset
				var basis = Basis().rotated(Vector3.UP, randf() * PI * 2.0)
				# Very low height (0.125) for a "short grass" look
				basis = basis.scaled(Vector3(randf_range(0.7, 1.3), 0.125, randf_range(0.7, 1.3)))
				grass_transforms.append(Transform3D(basis, grass_pos))

func generate_fixed_island() -> void:
	hexagon_data.clear()
	grass_transforms.clear()
	
	# Simple 8-block radius circular island
	var island_radius = 8
	for x in range(-island_radius, island_radius + 1):
		for z in range(-island_radius, island_radius + 1):
			var dist = sqrt(x*x + z*z)
			if dist > island_radius: continue
			
			# Determine height based on distance (sloped center)
			var h = 1
			if dist < 6: h = 2
			if dist < 3: h = 3
			
			generate_island_block(x, z, h)
			
	hexagon_mesh.generate_mesh(hexagon_data)
	_update_grass_multimesh(grass_transforms)

func _update_grass_multimesh(transforms: Array[Transform3D]) -> void:
	if not grass_multimesh or transforms.is_empty():
		return
		
	grass_multimesh.multimesh.instance_count = 0 # Clear previous
	grass_multimesh.multimesh.instance_count = transforms.size()
	for i in range(transforms.size()):
		grass_multimesh.multimesh.set_instance_transform(i, transforms[i])
