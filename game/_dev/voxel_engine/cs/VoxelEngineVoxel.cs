using Godot;
using System.Collections.Generic;

public abstract class VoxelEngineVoxel
{
	// A container struct for mesh data to avoid Dictionary overhead
	public struct GeometryData
	{
		public List<Vector3> Vertices;
		public List<Vector3> Normals;
		public List<Color> Colors;
		public List<Vector2> Uvs;
		public List<float> Tangents;

		public GeometryData(int initialCapacity)
		{
			Vertices = new List<Vector3>(initialCapacity);
			Normals = new List<Vector3>(initialCapacity);
			Colors = new List<Color>(initialCapacity);
			Uvs = new List<Vector2>(initialCapacity);
			Tangents = new List<float>(initialCapacity * 4);
		}
	}
	
	public static int GetIndex(int x, int y, int z, int size)
	{
		return x + (y * size) + (z * size * size);
	}

	public static void AddTriangle(
		Vector3 p1, Vector3 p2, Vector3 p3,
		Vector3 normal, Color color,
		List<Vector3> vertices, List<Vector3> normals, List<Color> colors)
	{
		vertices.Add(p1); vertices.Add(p2); vertices.Add(p3);
		normals.Add(normal); normals.Add(normal); normals.Add(normal);
		colors.Add(color); colors.Add(color); colors.Add(color);
	}

	public static void AddTexturedTriangle(
		Vector3 p1, Vector3 p2, Vector3 p3,
		Vector2 uv1, Vector2 uv2, Vector2 uv3,
		Vector3 normal, int textureIndex,
		GeometryData data)
	{
		data.Vertices.Add(p1); data.Vertices.Add(p2); data.Vertices.Add(p3);
		data.Normals.Add(normal); data.Normals.Add(normal); data.Normals.Add(normal);
		data.Uvs.Add(uv1); data.Uvs.Add(uv2); data.Uvs.Add(uv3);

		float t = (float)textureIndex;
		for (int i = 0; i < 3; i++)
		{
			data.Tangents.Add(t);
			data.Tangents.Add(0.0f);
			data.Tangents.Add(0.0f);
			data.Tangents.Add(1.0f);
		}
	}

	// --- Stubbed Methods for Overrides ---
	public static Vector2 GetNoiseCoordinates(int x, int z, Vector3 worldOrigin) => Vector2.Zero;
	public static Vector3I WorldToLocal(Vector3 worldPosition, Vector3 chunkOrigin) => Vector3I.Zero;
	public static Vector3I WorldToChunk(Vector3 worldPosition, int chunkSize) => Vector3I.Zero;
	public static Vector3 ChunkToWorld(Vector3I coordinate, int size) => Vector3.Zero;
	public static Vector3 VoxelToWorld(Vector3I voxel, Vector3 chunkOrigin) => Vector3.Zero;
	public static Vector3I VoxelToChunk(Vector3I voxel, int chunkSize) => Vector3I.Zero;
}
