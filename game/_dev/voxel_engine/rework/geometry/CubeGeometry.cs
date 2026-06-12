using Godot;
using System.Collections.Generic;

[GlobalClass]
public partial class CubeGeometry : Resource, IVoxelGeometry
{
	public enum Face
	{
		BOTTOM,
		FRONT,
		RIGHT,
		TOP,
		LEFT,
		BACK
	}

	public int FaceCount => 6;

	public Vector3[] Vertices { get; } =
	{
		new Vector3(0, 0, 1),
		new Vector3(1, 0, 1),
		new Vector3(1, 0, 0),
		new Vector3(0, 0, 0),

		new Vector3(0, 1, 1),
		new Vector3(1, 1, 1),
		new Vector3(1, 1, 0),
		new Vector3(0, 1, 0)
	};

	private readonly Dictionary<Face, int[][]> _faceIndices =
		new Dictionary<Face, int[][]>
	{
		{Face.FRONT,  new []{ new[]{0,4,5}, new[]{0,5,1}}},
		{Face.BACK,   new []{ new[]{2,7,3}, new[]{2,6,7}}},
		{Face.LEFT,   new []{ new[]{3,7,4}, new[]{3,4,0}}},
		{Face.RIGHT,  new []{ new[]{1,5,6}, new[]{1,6,2}}},
		{Face.BOTTOM, new []{ new[]{0,1,2}, new[]{0,2,3}}},
		{Face.TOP,    new []{ new[]{4,7,6}, new[]{4,6,5}}}
	};

	private readonly Dictionary<Face, Vector3> _normals =
		new Dictionary<Face, Vector3>
	{
		{Face.FRONT,  new Vector3(0, 0, 1)},
		{Face.BACK,   new Vector3(0, 0,-1)},
		{Face.LEFT,   new Vector3(-1,0, 0)},
		{Face.RIGHT,  new Vector3(1, 0, 0)},
		{Face.BOTTOM, new Vector3(0,-1, 0)},
		{Face.TOP,    new Vector3(0, 1, 0)}
	};

	public Vector3 GetNormal(int face)
	{
		return _normals[(Face)face];
	}

	public int[][] GetTriangles(int face)
	{
		return _faceIndices[(Face)face];
	}
	
	public Vector3I GetNeighborOffset(int face, Vector3I currentPos)
	{
		return (Face)face switch
		{
			Face.FRONT  => new Vector3I(0, 0, 1),
			Face.BACK   => new Vector3I(0, 0, -1),
			Face.LEFT   => new Vector3I(-1, 0, 0),
			Face.RIGHT  => new Vector3I(1, 0, 0),
			Face.BOTTOM => new Vector3I(0, -1, 0),
			Face.TOP    => new Vector3I(0, 1, 0),
			_           => Vector3I.Zero
		};
	}
	
	public Vector3 GetWorldPosition(Vector3I gridPos)
	{
		return new Vector3(gridPos.X, gridPos.Y, gridPos.Z);
	}
	
	public Vector3I WorldToGridPosition(Vector3 worldPos)
	{
		return new Vector3I(
			Mathf.FloorToInt(worldPos.X),
			Mathf.FloorToInt(worldPos.Y),
			Mathf.FloorToInt(worldPos.Z)
		);
	}
	
	public Vector2 GetUV(int face, int vertexIndex, int sideIndex = 0)
	{
		// Based on the quad index winding loops:
		
		return (vertexIndex % 4) switch
		{
			// Tri 1: [0, 1, 2] -> (0,1), (1,1), (1,0)
			0 => new Vector2(0f, 1f),
			1 => new Vector2(1f, 1f),
			2 => new Vector2(1f, 0f),
			3 => new Vector2(0f, 0f),
			
			// Tri 2: [0, 2, 3] -> (0,1), (1,0), (0,0)
			4 => new Vector2(0f, 1f),
			5 => new Vector2(1f, 1f),
			6 => new Vector2(1f, 0f),
			7 => new Vector2(0f, 0f),
			
			_ => Vector2.Zero
		};
	}
	
	public Vector3I GetChunkIndex(Vector3 worldPos, int chunkSize)
	{
		return new Vector3I(
			Mathf.FloorToInt(worldPos.X / chunkSize),
			Mathf.FloorToInt(worldPos.Y / chunkSize),
			Mathf.FloorToInt(worldPos.Z / chunkSize)
		);
	}

	public Vector3 GetChunkWorldOrigin(Vector3I chunkIndex, int chunk_size)
	{
		return new Vector3(chunkIndex.X * chunk_size, chunkIndex.Y * chunk_size, chunkIndex.Z * chunk_size);
	}

}
