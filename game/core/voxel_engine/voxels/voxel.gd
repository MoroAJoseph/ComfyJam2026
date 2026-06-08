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

## Generates geometry for exactly one voxel, useful for hover/highlighting
static func get_single_voxel_geometry(
	_voxel: Vector3i, _data: PackedByteArray, _coords: Vector3i, 
	_registry: Dictionary, _size: int, _color: Color
) -> Dictionary:
	return {"verts": PackedVector3Array(), "norms": PackedVector3Array(), "cols": PackedColorArray()}

static func get_index(x: int, y: int, z: int, size: int) -> int:
	return x + (y * size) + (z * size * size)

static func _add_tri(p1: Vector3, p2: Vector3, p3: Vector3, n: Vector3, c: Color, v: PackedVector3Array, no: PackedVector3Array, co: PackedColorArray, uvs: PackedVector2Array) -> void:
	v.append_array([p1, p2, p3])
	no.append_array([n, n, n])
	co.append_array([c, c, c])
	# Placeholder for UVs: initializes to zero for future texture mapping
	uvs.append_array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])

## Returns the sampling coordinate for the noise generator
static func get_noise_coords(_x: int, _z: int, world_origin: Vector3) -> Vector2: return Vector2.ZERO
## Converts a world-space position into a local Vector3i voxel index
static func world_to_local(world_pos: Vector3, chunk_origin: Vector3) -> Vector3i: return Vector3i.ZERO
## 
static func world_to_chunk(world_pos: Vector3, chunk_size: int) -> Vector3i: return Vector3i.ZERO
## 
static func chunk_to_world(coord: Vector3i, size: int) -> Vector3: return Vector3.ZERO
## 
static func voxel_to_world(voxel: Vector3i) -> Vector3: return Vector3.ZERO
##
static func voxel_to_chunk(voxel: Vector3i, chunk_size: int) -> Vector3i: return Vector3i.ZERO
