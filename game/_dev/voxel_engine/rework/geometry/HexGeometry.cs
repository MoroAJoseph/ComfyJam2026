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
	
	private static readonly float CanvasSize = 512f;
	private static readonly float PixelCenterX = 256f;
	private static readonly float PixelCenterY = 256f;
	private static readonly float HexRadius = 64f;
	private static readonly float Apothem = HexRadius * Mathf.Sqrt(3f) / 2f;
	
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

		// IMPORTANT: use GLOBAL Z so hex staggering is consistent across chunks
		if (gridPos.Z % 2 != 0)
		{
			xPos += r;
		}

		float zPos = gridPos.Z * (R * 1.5f);
		float yPos = gridPos.Y * H;

		return new Vector3(xPos, yPos, zPos);
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

		// Convert world positions into pure, un-rounded axial layout fractions
		float q_frac = (Mathf.Sqrt(3f) / 3f * worldPos.X - 1f / 3f * worldPos.Z) / 1.0f;
		float r_frac = (2f / 3f * worldPos.Z) / 1.0f;
		float s_frac = -q_frac - r_frac;

		// Perform safe, standard Cube Rounding
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

		// Translate the validated axial coordinate space straight back to the staggered array system
		int z_final = r_int;
		
		// Determine layout offsets accurately using the precise GetWorldPosition spacing criteria
		float x_offset = (Mathf.Abs(z_final) % 2 != 0) ? r_rad : 0.0f;
		int x_final = Mathf.RoundToInt((worldPos.X - x_offset) / (r_rad * 2.0f));
		
		int y_final = Mathf.FloorToInt(worldPos.Y);

		return new Vector3I(x_final, y_final, z_final);
	}
	
	public Vector2 GetUV(int face, int vertexIndex, int sideIndex = 0)
	{
		float cx = PixelCenterX / CanvasSize;
		
		if (face == (int)Face.TOP)
		{
			float cy = (PixelCenterY - 32f - Apothem) / CanvasSize;
			return CalculateCapUV(cx, cy, vertexIndex);
		}
		if (face == (int)Face.BOTTOM)
		{
			float cy = (PixelCenterY + 32f + Apothem) / CanvasSize;
			return CalculateCapUV(cx, cy, vertexIndex);
		}

		// --- SIDE WALL CENTERING FIX ---
		int[][] triangles = GetTriangles(face);
		int localCornerIndex = -1;
		System.Collections.Generic.List<int> uniqueFaceVertices = new System.Collections.Generic.List<int>();
		
		foreach (int[] tri in triangles)
		{
			foreach (int vIdx in tri)
			{
				if (!uniqueFaceVertices.Contains(vIdx))
				{
					uniqueFaceVertices.Add(vIdx);
				}
				if (vIdx == vertexIndex)
				{
					localCornerIndex = uniqueFaceVertices.IndexOf(vIdx);
				}
			}
		}

		// Define the UV fractional bounds of the 64x64 square centered on the 512x512 canvas
		// Min: 224 / 512 = 0.4375
		// Max: 288 / 512 = 0.5625
		float uvMin = 224f / CanvasSize;
		float uvMax = 288f / CanvasSize;

		// Map the 4 corners of the quad panel explicitly to the borders of the 64x64 pixel box
		return localCornerIndex switch
		{
			0 => new Vector2(uvMin, uvMax), // Bottom-Left
			1 => new Vector2(uvMax, uvMax), // Bottom-Right
			2 => new Vector2(uvMax, uvMin), // Top-Right
			3 => new Vector2(uvMin, uvMin), // Top-Left
			_ => Vector2.Zero
		};
	}
	
	private Vector2 CalculateCapUV(float cx, float cy, int vertexIndex)
	{
		if (vertexIndex == 12) return new Vector2(cx, cy); // Center point fallback

		float angle = Mathf.DegToRad(60f * (vertexIndex % 6));
		float u = cx + (Mathf.Cos(angle) * HexRadius) / CanvasSize;
		float v = cy + (Mathf.Sin(angle) * HexRadius) / CanvasSize;
		return new Vector2(u, v);
	}
	
	public Vector3I GetChunkIndex(Vector3 worldPos, int chunkSize)
	{
		int chunkX = Mathf.FloorToInt(worldPos.X / (chunkSize * r * 2.0f));
		int chunkY = Mathf.FloorToInt(worldPos.Y / chunkSize);
		int chunkZ = Mathf.FloorToInt(worldPos.Z / (chunkSize * R * 1.5f));

		return new Vector3I(chunkX, chunkY, chunkZ);
	} 

	public Vector3 GetChunkWorldOrigin(Vector3I chunkIndex, int chunkSize)
	{
		Vector3I voxelOrigin = new Vector3I(
			chunkIndex.X * chunkSize,
			chunkIndex.Y * chunkSize,
			chunkIndex.Z * chunkSize
		);

		return GetWorldPosition(voxelOrigin);
	}
}
