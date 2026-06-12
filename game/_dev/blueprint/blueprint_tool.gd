@tool
class_name VoxelEngineBlueprintTool extends Node3D

enum Algorithm { ISLAND, DOCK_ISLAND }

@export var save: bool:
	set(value): save_to_resource()
@export var blueprint_data: VoxelEngineBlueprintData
@export var generate: bool:
	set(value): generate_blueprint()
@export var generate_random: bool:
	set(v): if v: 
		noise_seed = randi()
		generate_blueprint()

@export_group("Generation Settings")
@export var use_hexagons: bool = false
@export var algorithm: Algorithm = Algorithm.ISLAND
@export var dimensions: Vector3i = Vector3i(16, 16, 16)
@export var side_padding: int
@export var noise_seed: int = 0:
	set(v): 
		noise_seed = v
		notify_property_list_changed()
@export var randomize_seed: bool:
	set(v): 
		if v: noise_seed = randi()

@export_group("Island Settings")
@export var cave_weights: Array[float] = []
@export var dock_weights: Array[float] = [1.0]
@export_range(0.0, 1.0, 0.01) var flatness_gauge: float = 0.5
@export var max_island_height: int
@export var boat_height: int = 3
@export var cave_tunnel_radius: float = 2.5
@export var sea_height: float = 1.0
@export var spawn_rules: Array[VoxelEngineBlueprintSpawnRule] = []

@onready var logic_class: Object = VoxelEngineHexagon if use_hexagons else VoxelEngineCube

var voxel_data: Dictionary[Vector3i, int] = {}

func generate_blueprint() -> void:
	voxel_data.clear()
	
	match algorithm:
		Algorithm.ISLAND:
			voxel_data = VoxelEngineBlueprintGenerator.generate_terrain(
				dimensions, 
				noise_seed, 
				max_island_height, 
				sea_height
			)
		Algorithm.DOCK_ISLAND:
			var heightmap = VoxelEngineBlueprintGenerator.generate_dock_island(
				Vector2i(dimensions.x, dimensions.z), 
				noise_seed, 
				dock_weights,
				flatness_gauge,
				max_island_height
				)
			voxel_data = _heightmap_to_voxels_with_caves(
				heightmap, 
				dimensions, 
				sea_height, 
				cave_weights, 
				cave_tunnel_radius
			)
	
	update_preview()
	print("Generated blueprint with %d voxels" % voxel_data.size())

func _heightmap_to_voxels(
	heightmap: Array[float], 
	dims: Vector3i, 
	sea_h: float
) -> Dictionary[Vector3i, int]:
	var data: Dictionary[Vector3i, int] = {}
	
	for x in dims.x:
		for z in dims.z:
			var h = int(clampf(heightmap[x + z * dims.x], 0.0, float(dims.y)))
			for y in range(h):
				if float(y) >= sea_h:
					data[Vector3i(x, y, z)] = 1
	
	return data

func _heightmap_to_voxels_with_caves(heightmap, dims, sea_h, cave_weights, radius) -> Dictionary[Vector3i, int]:
	return VoxelEngineBlueprintGenerator.generate_dock_voxels(
		heightmap, 
		dims, 
		sea_h, 
		noise_seed, 
		radius, 
		cave_weights, 
		spawn_rules
	)

func _force_cave_entrances(data: Dictionary, dims: Vector3i, sea_h: float) -> void:
	for x in range(dims.x):
		for z in range(dims.z):

			# only at shoreline columns
			if randi() % 40 != 0:
				continue

			# carve vertical shaft from sea into terrain
			for y in range(int(sea_h), int(sea_h) + 6):
				data[Vector3i(x, y, z)] = 0

func save_to_resource() -> void:
	if not blueprint_data:
		print_debug("No blueprint data")
		return
	bake_to_blueprint_data()
	#ResourceSaver.save(data, "res://common/data/voxel_blueprints/")
	print_debug("Island Saved!")

func bake_to_blueprint_data() -> void:
	var geometry := _generate_culled_mesh()
	blueprint_data.mesh_arrays = geometry
	blueprint_data.collision_verts = geometry.verts
	blueprint_data.block_map = voxel_data.duplicate() # Save the map
	blueprint_data.emit_changed() # Ensure Inspector saves the resource

func _generate_culled_mesh() -> Dictionary:
	if voxel_data.is_empty(): return {"verts": PackedVector3Array(), "norms": PackedVector3Array(), "cols": PackedColorArray(), "uvs": PackedVector2Array()}
	
	var min_bound := Vector3i(999, 999, 999)
	var max_bound := Vector3i(-999, -999, -999)
	for pos in voxel_data.keys():
		min_bound = min_bound.min(pos)
		max_bound = max_bound.max(pos)
	
	var size := (max_bound - min_bound) + Vector3i.ONE
	var dense_data := PackedByteArray()
	dense_data.resize(size.x * size.y * size.z)
	dense_data.fill(0)
	
	for pos in voxel_data:
		var local := pos - min_bound
		dense_data[local.x + (local.y * size.x) + (local.z * size.x * size.y)] = voxel_data[pos]
		
	return logic_class.calculate_geometry(
		dense_data, 
		Vector3i.ZERO, {}, size.x, [Color.WHITE])

func update_preview() -> void:
	if voxel_data.is_empty():
		var old = get_node_or_null("PreviewNode")
		if old: old.free()
		return

	# Calculate Center of Mass using Hex Math
	var center := Vector3.ZERO
	for pos in voxel_data.keys():
		center += VoxelEngineHexagon.get_hex_world_position(pos, 1.0, 1.0) if use_hexagons else Vector3(pos)
	center /= float(voxel_data.size())

	# Setup Node
	var mm_instance = get_node_or_null("PreviewNode")
	if not mm_instance:
		mm_instance = MultiMeshInstance3D.new()
		mm_instance.name = "PreviewNode"
		add_child(mm_instance)
		if Engine.is_editor_hint():
			mm_instance.owner = get_tree().edited_scene_root

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = voxel_data.size()
	
	# Assign Mesh
	if use_hexagons:
		var hex := CylinderMesh.new()
		hex.radial_segments = 6
		hex.top_radius = 1.0
		hex.bottom_radius = 1.0
		hex.height = 1.0
		mm.mesh = hex
	else:
		mm.mesh = BoxMesh.new()
		mm.mesh.size = Vector3.ONE

	mm_instance.multimesh = mm

	# Apply centered transforms with 30-degree rotation per instance
	var i := 0
	# Create the rotation basis once to save performance
	var edge_alignment_basis := Basis.from_euler(Vector3(0, deg_to_rad(30), 0))
	
	for pos in voxel_data.keys():
		var world_pos = VoxelEngineHexagon.get_hex_world_position(pos, 1.0, 1.0) if use_hexagons else Vector3(pos)
		
		var new_transform := Transform3D(Basis(), world_pos - center)
		if use_hexagons:
			# Apply the 30-degree rotation to each instance so the flat edge faces out
			new_transform.basis = edge_alignment_basis
			
		mm.set_instance_transform(i, new_transform)
		i += 1
