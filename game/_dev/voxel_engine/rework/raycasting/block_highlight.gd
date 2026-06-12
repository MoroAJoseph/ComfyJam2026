class_name BlockHighlight extends Node3D

@export var ray: RayCast3D
@export var chunk_manager: ChunkManager

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var current_geometry_type: String = ""

func _physics_process(_delta: float) -> void:
	if not ray.is_colliding() or not chunk_manager or not chunk_manager.meshing_algorithm:
		visible = false
		return
		
	var geom = chunk_manager.meshing_algorithm.ScriptGeometry
	if not geom:
		visible = false
		return

	visible = true
	
	var is_hex: bool = "FaceCount" in geom and geom.FaceCount == 8
	var target_type_sig = "HEX" if is_hex else "CUBE"
	
	if target_type_sig != current_geometry_type:
		_update_highlight_mesh(is_hex)

	var hit_point = ray.get_collision_point()
	var hit_normal = ray.get_collision_normal()
	
	# --- THE EDGE FIX ---
	# To stop side-to-side edge slipping, we find the primary cardinal direction of the hit normal.
	# We force the nudge to strictly counteract that single face direction, ignoring corner drift.
	var clean_nudge = Vector3.ZERO
	if abs(hit_normal.x) > abs(hit_normal.y) and abs(hit_normal.x) > abs(hit_normal.z):
		clean_nudge.x = sign(hit_normal.x) * 0.02
	elif abs(hit_normal.y) > abs(hit_normal.z):
		clean_nudge.y = sign(hit_normal.y) * 0.02
	else:
		clean_nudge.z = sign(hit_normal.z) * 0.02
		
	var remove_world_sample = hit_point - clean_nudge
	var grid_pos = geom.WorldToGridPosition(remove_world_sample)
	var block_center_pos = geom.GetWorldPosition(grid_pos)
	
	if is_hex:
		block_center_pos.y += 0.5
	else:
		block_center_pos += Vector3(0.5, 0.5, 0.5)
		
	if block_center_pos != global_position:
		global_position = block_center_pos


func _update_highlight_mesh(is_hex: bool) -> void:
	current_geometry_type = "HEX" if is_hex else "CUBE"
	var scale_factor: float = 1.02
	
	if is_hex:
		var cylinder = CylinderMesh.new()
		cylinder.radial_segments = 6   
		cylinder.top_radius = 1.0 * scale_factor
		cylinder.bottom_radius = 1.0 * scale_factor
		cylinder.height = 1.0 * scale_factor
		
		mesh_instance.mesh = cylinder
	
	else:
		var box = BoxMesh.new()
		box.size = Vector3(1.0, 1.0, 1.0) * scale_factor
		
		mesh_instance.mesh = box
		
	var material = StandardMaterial3D.new()
	material.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 1.0, 1.0, 0.25) 
	material.roughness = 1.0
	material.emission_enabled = true
	material.emission = Color(1.0, 1.0, 1.0)
	material.emission_energy_multiplier = 0.15
	
	mesh_instance.material_override = material
