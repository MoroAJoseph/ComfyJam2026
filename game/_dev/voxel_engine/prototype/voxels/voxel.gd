class_name VoxelEngineVoxel 
extends RefCounted

## Base class for Voxel geometry generation strategies.
static func calculate_geometry(
	_data: PackedByteArray, 
	_coords: Vector3i, 
	_registry: Dictionary, 
	_size: int, 
	_colors: Array[Color]
) -> Dictionary:
	return {
		"verts": PackedVector3Array(), 
		"norms": PackedVector3Array(), 
		"cols": PackedColorArray()
	}
	
## Returns the sampling coordinate for the noise generator
static func get_noise_coords(_x: int, _z: int, world_origin: Vector3) -> Vector2:
	return Vector2(world_origin.x + float(_x), world_origin.z + float(_z))
