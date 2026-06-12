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
}
