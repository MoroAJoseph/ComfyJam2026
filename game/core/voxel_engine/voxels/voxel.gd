class_name VoxelEngineVoxel
extends RefCounted

## Base class for Voxel geometry generation strategies.
static func calculate_geometry(
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	size: int,
	colors: Array[Color]
) -> Dictionary:
	return {
		"vertices": PackedVector3Array(),
		"normals": PackedVector3Array(),
		"colors": PackedColorArray()
	}

## Generates geometry for exactly one voxel, useful for hover/highlighting.
static func get_single_voxel_geometry(
	voxel_position: Vector3i,
	data: PackedByteArray,
	coordinates: Vector3i,
	registry: Dictionary,
	size: int,
	color: Color
) -> Dictionary:
	return {
		"vertices": PackedVector3Array(),
		"normals": PackedVector3Array(),
		"colors": PackedColorArray()
	}

## Calculates a 1D index from 3D coordinates for a flattened array.
static func get_index(x: int, y: int, z: int, size: int) -> int:
	return x + (y * size) + (z * size * size)

## Appends triangle data to the provided vertex, normal, and color arrays.
static func add_triangle(
	point1: Vector3,
	point2: Vector3,
	point3: Vector3,
	normal: Vector3,
	color: Color,
	vertices: PackedVector3Array,
	normals: PackedVector3Array,
	colors: PackedColorArray
) -> void:
	vertices.append_array([point1, point2, point3])
	normals.append_array([normal, normal, normal])
	colors.append_array([color, color, color])

## Returns the sampling coordinate for the noise generator.
static func get_noise_coordinates(x: int, z: int, world_origin: Vector3) -> Vector2:
	return Vector2.ZERO

## Converts a world-space position into a local Vector3i voxel index.
static func world_to_local(world_position: Vector3, chunk_origin: Vector3) -> Vector3i:
	return Vector3i.ZERO

## Maps a world-space position to its corresponding chunk coordinate.
static func world_to_chunk(world_position: Vector3, chunk_size: int) -> Vector3i:
	return Vector3i.ZERO

## Converts chunk coordinates to world-space position.
static func chunk_to_world(coordinate: Vector3i, size: int) -> Vector3:
	return Vector3.ZERO

## Converts a specific voxel coordinate to world-space position.
static func voxel_to_world(voxel: Vector3i, chunk_origin: Vector3) -> Vector3:
	return Vector3.ZERO

## Maps a specific voxel coordinate to its parent chunk coordinate.
static func voxel_to_chunk(voxel: Vector3i, chunk_size: int) -> Vector3i:
	return Vector3i.ZERO
