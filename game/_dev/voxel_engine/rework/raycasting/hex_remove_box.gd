class_name HexRemoveBox 
extends CSGCylinder3D

@export var ray: RayCast3D
@export var chunk_manager: ChunkManager

func _physics_process(_delta: float) -> void:
	if ray.is_colliding() and chunk_manager.meshing_algorithm and chunk_manager.meshing_algorithm.ScriptGeometry:
		visible = true
		var geom = chunk_manager.meshing_algorithm.ScriptGeometry
		
		var hit_point = ray.get_collision_point()
		var hit_normal = ray.get_collision_normal()
		
		# Find the grid index position using the active shape logic
		var remove_world_sample = hit_point - (hit_normal * 0.01)
		var grid_pos = geom.WorldToGridPosition(remove_world_sample)
		
		# Pull the center origin position of that specific cell block layout
		var block_center_pos = geom.GetWorldPosition(grid_pos)
		
		# Pointy-topped cylinders are centered perfectly around their origin, 
		# but need a half-height vertical offset up if their origin point sits at the base loop
		block_center_pos.y += 0.5 
		
		if block_center_pos != global_position:
			global_position = block_center_pos
	else:
		visible = false
