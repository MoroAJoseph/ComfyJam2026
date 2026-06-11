using Godot;
using System.Collections.Generic;

public static class VoxelConstants
{
	public static readonly Dictionary<VoxelEngineEnums.BlockType, int> BLOCK_TO_TEXTURE_INDEX = new()
	{
		{ VoxelEngineEnums.BlockType.Cobblestone, 0 },
		{ VoxelEngineEnums.BlockType.MossyCobblestone, 1 },
		{ VoxelEngineEnums.BlockType.Stone, 2 },
		{ VoxelEngineEnums.BlockType.Sand, 3 },
		{ VoxelEngineEnums.BlockType.Grass, 4 },
		{ VoxelEngineEnums.BlockType.Dirt, 5 }
	};

	public static class Cube
	{
		public static readonly Vector3[] Vertices = {
			new(-0.5f, -0.5f,  0.5f), new( 0.5f, -0.5f,  0.5f),
			new( 0.5f, -0.5f, -0.5f), new(-0.5f, -0.5f, -0.5f),
			new(-0.5f,  0.5f,  0.5f), new( 0.5f,  0.5f,  0.5f),
			new( 0.5f,  0.5f, -0.5f), new(-0.5f,  0.5f, -0.5f)
		};

		public static readonly Dictionary<VoxelEngineEnums.CubeFace, int[][]> FaceIndices = new() {
			{ VoxelEngineEnums.CubeFace.Front,  new[] { new[] { 0, 4, 5 }, new[] { 0, 5, 1 } } },
			{ VoxelEngineEnums.CubeFace.Back,   new[] { new[] { 2, 7, 3 }, new[] { 2, 6, 7 } } },
			{ VoxelEngineEnums.CubeFace.Left,   new[] { new[] { 3, 7, 4 }, new[] { 3, 4, 0 } } },
			{ VoxelEngineEnums.CubeFace.Right,  new[] { new[] { 1, 5, 6 }, new[] { 1, 6, 2 } } },
			{ VoxelEngineEnums.CubeFace.Top,    new[] { new[] { 0, 1, 2 }, new[] { 0, 2, 3 } } },
			{ VoxelEngineEnums.CubeFace.Bottom, new[] { new[] { 4, 7, 6 }, new[] { 4, 6, 5 } } }
		};

		public static readonly Dictionary<VoxelEngineEnums.CubeFace, Vector3> FaceNormals = new() {
			{ VoxelEngineEnums.CubeFace.Front,  Vector3.Forward },
			{ VoxelEngineEnums.CubeFace.Back,   Vector3.Back },
			{ VoxelEngineEnums.CubeFace.Left,   Vector3.Left },
			{ VoxelEngineEnums.CubeFace.Right,  Vector3.Right },
			{ VoxelEngineEnums.CubeFace.Top,    Vector3.Down },
			{ VoxelEngineEnums.CubeFace.Bottom, Vector3.Up }
		};
	}

	public static class Hexagon
	{
		public static readonly Vector3I[] FACE_TO_NEIGHBOR = {
			new(1, 0, 0), new(0, 0, 1), new(-1, 0, 1),
			new(-1, 0, 0), new(0, 0, -1), new(1, 0, -1)
		};

		public const float AtlasSize = 512.0f;
		public const float PixelRadius = 64.0f;
		public static readonly float Apothem = PixelRadius * Mathf.Sqrt(3.0f) / 2.0f;
		public const float PixelCenterX = 256.0f;
		public const float PixelCenterY = 256.0f;

		public static readonly Dictionary<string, Vector2[]> UvMap = new()
		{
			{ "TOP", GetHexUvs(PixelCenterY - 32.0f - Apothem) },
			{ "BOTTOM", GetHexUvs(PixelCenterY + 32.0f + Apothem) },
			{ "SIDE", new[] {
				new Vector2(224.0f, 224.0f) / AtlasSize,
				new Vector2(288.0f, 224.0f) / AtlasSize,
				new Vector2(288.0f, 288.0f) / AtlasSize,
				new Vector2(224.0f, 288.0f) / AtlasSize
			}}
		};

		private static Vector2[] GetHexUvs(float centerY)
		{
			return new Vector2[] {
				new Vector2(PixelCenterX - PixelRadius, centerY) / AtlasSize,
				new Vector2(PixelCenterX - PixelRadius / 2.0f, centerY - Apothem) / AtlasSize,
				new Vector2(PixelCenterX + PixelRadius / 2.0f, centerY - Apothem) / AtlasSize,
				new Vector2(PixelCenterX + PixelRadius, centerY) / AtlasSize,
				new Vector2(PixelCenterX + PixelRadius / 2.0f, centerY + Apothem) / AtlasSize,
				new Vector2(PixelCenterX - PixelRadius / 2.0f, centerY + Apothem) / AtlasSize
			};
		}
	}
}
