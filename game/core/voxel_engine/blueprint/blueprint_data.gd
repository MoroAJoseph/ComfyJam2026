class_name VoxelEngineBlueprintData
extends Resource

@export var mesh_arrays: Dictionary
@export var collision_verts: PackedVector3Array

func _init(
	p_mesh_arrays: Dictionary, 
	p_collision_verts: PackedVector3Array
) -> void:
	mesh_arrays = p_mesh_arrays
	collision_verts = p_collision_verts
