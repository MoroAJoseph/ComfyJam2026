using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class HexGeometry : Resource, IVoxelGeometry
{
	public enum Face
	{
		BOTTOM,
		TOP,
		NORTH_EAST, // Pointy-topped hexes have 6 side faces angled into diagonals or horizontal flats
		EAST,
		SOUTH_EAST,
		SOUTH_WEST,
		WEST,
		NORTH_WEST
	}

	public int FaceCount => 8;

	private static readonly float H = 1.0f; 
	private static readonly float R = 1.0f; 
	private static readonly float r = R * Mathf.Sqrt(3) / 2.0f; 

	// Vertices rotated by 30 degrees so the flat edges match your interlocking grid step math
	public Vector3[] Vertices { get; } =
	{
		// Bottom Loop (y = 0)
		new Vector3(r, 0, -R * 0.5f),  // 0
		new Vector3(r, 0, R * 0.5f),   // 1
		new Vector3(0, 0, R),          // 2
		new Vector3(-r, 0, R * 0.5f),  // 3
		new Vector3(-r, 0, -R * 0.5f), // 4
		new Vector3(0, 0, -R),         // 5

		// Top Loop (y = H)
		new Vector3(r, H, -R * 0.5f),  // 6
		new Vector3(r, H, R * 0.5f),   // 7
		new Vector3(0, H, R),          // 8
		new Vector3(-r, H, R * 0.5f),  // 9
		new Vector3(-r, H, -R * 0.5f), // 10
		new Vector3(0, H, -R)          // 11
	};

	private readonly Dictionary<Face, int[][]> _faceIndices = new Dictionary<Face, int[][]>
	{
		// Clockwise face indexing to match your setup
		{ Face.BOTTOM, new []{ new[]{0,2,1}, new[]{0,3,2}, new[]{0,4,3}, new[]{0,5,4} } },
		{ Face.TOP,    new []{ new[]{6,7,8}, new[]{6,8,9}, new[]{6,9,10}, new[]{6,10,11} } },

		// Side walls mapped explicitly to the rotated vertices
		{ Face.NORTH_EAST, new []{ new[]{5,0,6}, new[]{5,6,11} } },
		{ Face.EAST,       new []{ new[]{0,1,7}, new[]{0,7,6} } },
		{ Face.SOUTH_EAST, new []{ new[]{1,2,8}, new[]{1,8,7} } },
		{ Face.SOUTH_WEST, new []{ new[]{2,3,9}, new[]{2,9,8} } },
		{ Face.WEST,       new []{ new[]{3,4,10}, new[]{3,10,9} } },
		{ Face.NORTH_WEST, new []{ new[]{4,5,11}, new[]{4,11,10} } }
	};

	private readonly Dictionary<Face, Vector3> _normals = new Dictionary<Face, Vector3>
	{
		{ Face.BOTTOM,     new Vector3(0, -1, 0) },
		{ Face.TOP,        new Vector3(0, 1, 0) },
		{ Face.NORTH_EAST, new Vector3(0.5f, 0, -Mathf.Sqrt(3)/2f).Normalized() },
		{ Face.EAST,       new Vector3(1, 0, 0) },
		{ Face.SOUTH_EAST, new Vector3(0.5f, 0, Mathf.Sqrt(3)/2f).Normalized() },
		{ Face.SOUTH_WEST, new Vector3(-0.5f, 0, Mathf.Sqrt(3)/2f).Normalized() },
		{ Face.WEST,       new Vector3(-1, 0, 0) },
		{ Face.NORTH_WEST, new Vector3(-0.5f, 0, -Mathf.Sqrt(3)/2f).Normalized() }
	};

	public Vector3 GetNormal(int face) => _normals[(Face)face];
	public int[][] GetTriangles(int face) => _faceIndices[(Face)face];

	public Vector3 GetWorldPosition(Vector3I gridPos)
	{
		float xPos = gridPos.X * (r * 2.0f);
		if (gridPos.Z % 2 != 0)
		{
			xPos += r;
		}
		float zPos = gridPos.Z * (R * 1.5f);
		return new Vector3(xPos, gridPos.Y * H, zPos);
	}

	public Vector3I GetNeighborOffset(int face, Vector3I currentPos)
	{
		// The Z axis determines if we are on a staggered row line
		bool isOddRow = Mathf.Abs(currentPos.Z) % 2 != 0;

		return (Face)face switch
		{
			Face.BOTTOM => new Vector3I(0, -1, 0),
			Face.TOP    => new Vector3I(0, 1, 0),
			
			// Pure horizontal rows steps
			Face.EAST   => new Vector3I(1, 0, 0),
			Face.WEST   => new Vector3I(-1, 0, 0),
			
			// Staggered zig-zag diagonal row jumps
			Face.NORTH_EAST => isOddRow ? new Vector3I(1, 0, -1) : new Vector3I(0, 0, -1),
			Face.NORTH_WEST => isOddRow ? new Vector3I(0, 0, -1) : new Vector3I(-1, 0, -1),
			Face.SOUTH_EAST => isOddRow ? new Vector3I(1, 0, 1)  : new Vector3I(0, 0, 1),
			Face.SOUTH_WEST => isOddRow ? new Vector3I(0, 0, 1)  : new Vector3I(-1, 0, 1),
			_ => Vector3I.Zero
		};
	}
	
	public Vector3I WorldToGridPosition(Vector3 worldPos)
	{
		float r_rad = Mathf.Sqrt(3.0f) / 2.0f;

		// 1. Convert world positions into pure, un-rounded axial layout fractions
		// This directly projects your world coordinates onto a clean axial basis vector frame
		float q_frac = (Mathf.Sqrt(3f) / 3f * worldPos.X - 1f / 3f * worldPos.Z) / 1.0f;
		float r_frac = (2f / 3f * worldPos.Z) / 1.0f;
		float s_frac = -q_frac - r_frac;

		// 2. Perform safe, standard Cube Rounding
		int q_int = Mathf.RoundToInt(q_frac);
		int r_int = Mathf.RoundToInt(r_frac);
		int s_int = Mathf.RoundToInt(s_frac);

		float q_diff = Mathf.Abs(q_int - q_frac);
		float r_diff = Mathf.Abs(r_int - r_frac);
		float s_diff = Mathf.Abs(s_int - s_frac);

		if (q_diff > r_diff && q_diff > s_diff)
		{
			q_int = -r_int - s_int;
		}
		else if (r_diff > s_diff)
		{
			r_int = -q_int - s_int;
		}

		// 3. Translate the validated axial coordinate space straight back to your staggered array system
		int z_final = r_int;
		
		// Determine layout offsets accurately using your precise GetWorldPosition spacing criteria
		float x_offset = (Mathf.Abs(z_final) % 2 != 0) ? r_rad : 0.0f;
		int x_final = Mathf.RoundToInt((worldPos.X - x_offset) / (r_rad * 2.0f));
		
		int y_final = Mathf.FloorToInt(worldPos.Y);

		return new Vector3I(x_final, y_final, z_final);
	}
}
