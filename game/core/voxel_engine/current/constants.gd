class_name VoxelEngineConstants
extends RefCounted

const BLOCK_TO_TEXTURE_INDEX: Dictionary[Enums.BlockType, int] = {
	Enums.BlockType.COBBLESTONE: 0,
	Enums.BlockType.MOSSY_COBBLESTONE: 1,
	Enums.BlockType.STONE: 2,
	Enums.BlockType.SAND: 3,
	Enums.BlockType.GRASS: 4,
	Enums.BlockType.DIRT: 5,
}

class Cube:
	
	## Defines the 8 corner vertices of a unit cube centered at the origin.
	const VERTICES: Array[Vector3] = [
		Vector3(-0.5, -0.5, 0.5), 
		Vector3(0.5, -0.5, 0.5),
		Vector3(0.5, -0.5, -0.5),
		Vector3(-0.5, -0.5, -0.5),
		Vector3(-0.5, 0.5, 0.5), 
		Vector3(0.5, 0.5, 0.5),
		Vector3(0.5, 0.5, -0.5), 
		Vector3(-0.5, 0.5, -0.5)
	]

	## Mapping of cube faces to the triangle indices that form them.
	const FACE_INDICES: Dictionary[VoxelEngineEnums.CubeFace, Array] = {
		VoxelEngineEnums.CubeFace.FRONT: [[0, 4, 5], [0, 5, 1]],
		VoxelEngineEnums.CubeFace.BACK: [[2, 7, 3], [2, 6, 7]],
		VoxelEngineEnums.CubeFace.LEFT: [[3, 7, 4], [3, 4, 0]],
		VoxelEngineEnums.CubeFace.RIGHT: [[1, 5, 6], [1, 6, 2]],
		VoxelEngineEnums.CubeFace.TOP: [[0, 1, 2], [0, 2, 3]],
		VoxelEngineEnums.CubeFace.BOTTOM: [[4, 7, 6], [4, 6, 5]]
	}

	## Normal vectors associated with each face of the cube.
	const FACE_NORMALS: Dictionary[VoxelEngineEnums.CubeFace, Vector3] = {
		VoxelEngineEnums.CubeFace.FRONT: Vector3(0, 0, 1), 
		VoxelEngineEnums.CubeFace.BACK: Vector3(0, 0, -1),
		VoxelEngineEnums.CubeFace.LEFT: Vector3(-1, 0, 0), 
		VoxelEngineEnums.CubeFace.RIGHT: Vector3(1, 0, 0),
		VoxelEngineEnums.CubeFace.TOP: Vector3(0, -1, 0), 
		VoxelEngineEnums.CubeFace.BOTTOM: Vector3(0, 1, 0)
	}

class Hexagon:
	
	## Neighbors for a hex grid in axial coordinate space.
	const FACE_TO_NEIGHBOR: Array[Vector3i] = [
		Vector3i(1, 0, 0), 
		Vector3i(0, 0, 1), 
		Vector3i(-1, 0, 1),
		Vector3i(-1, 0, 0), 
		Vector3i(0, 0, -1), 
		Vector3i(1, 0, -1)
	]

	const ATLAS_SIZE: float = 512.0
	const PIXEL_RADIUS: float = 64.0
	const APOTHEM: float = PIXEL_RADIUS * sqrt(3) / 2
	const PIXEL_CENTER_X: float = 256.0
	const PIXEL_CENTER_Y: float = 256.0
	
	const UV_MAP: Dictionary = {
		"TOP": [
			Vector2(PIXEL_CENTER_X - PIXEL_RADIUS, PIXEL_CENTER_Y - 32.0 - APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X - PIXEL_RADIUS / 2.0, PIXEL_CENTER_Y - 32.0 - APOTHEM - APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X + PIXEL_RADIUS / 2.0, PIXEL_CENTER_Y - 32.0 - APOTHEM - APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X + PIXEL_RADIUS, PIXEL_CENTER_Y - 32.0 - APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X + PIXEL_RADIUS / 2.0, PIXEL_CENTER_Y - 32.0 - APOTHEM + APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X - PIXEL_RADIUS / 2.0, PIXEL_CENTER_Y - 32.0 - APOTHEM + APOTHEM) / ATLAS_SIZE
		],
		"SIDE": [
			Vector2(224.0, 224.0) / ATLAS_SIZE,
			Vector2(288.0, 224.0) / ATLAS_SIZE,
			Vector2(288.0, 288.0) / ATLAS_SIZE,
			Vector2(224.0, 288.0) / ATLAS_SIZE
		],
		"BOTTOM": [
			Vector2(PIXEL_CENTER_X - PIXEL_RADIUS, PIXEL_CENTER_Y + 32.0 + APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X - PIXEL_RADIUS / 2.0, PIXEL_CENTER_Y + 32.0 + APOTHEM - APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X + PIXEL_RADIUS / 2.0, PIXEL_CENTER_Y + 32.0 + APOTHEM - APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X + PIXEL_RADIUS, PIXEL_CENTER_Y + 32.0 + APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X + PIXEL_RADIUS / 2.0, PIXEL_CENTER_Y + 32.0 + APOTHEM + APOTHEM) / ATLAS_SIZE,
			Vector2(PIXEL_CENTER_X - PIXEL_RADIUS / 2.0, PIXEL_CENTER_Y + 32.0 + APOTHEM + APOTHEM) / ATLAS_SIZE
		]
	}
