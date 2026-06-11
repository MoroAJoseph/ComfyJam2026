using Godot;
using System;
using System.Collections.Generic;

public static class VoxelEngineHexagon
{
	public static VoxelEngineVoxel.GeometryData CalculateChunkGeometry(
		byte[] data, 
		Vector3I coordinates, 
		Dictionary<Vector3I, byte[]> registry, 
		int chunkSize, 
		Color[] colors)
	{
		var result = new VoxelEngineVoxel.GeometryData(chunkSize * chunkSize * chunkSize * 18);

		for (int x = 0; x < chunkSize; x++)
		{
			for (int y = 0; y < chunkSize; y++)
			{
				for (int z = 0; z < chunkSize; z++)
				{
					int index = VoxelEngineVoxel.GetIndex(x, y, z, chunkSize);
					if (data[index] == 0) continue;

					Color voxelColor = colors[data[index] - 1];
					Vector3 center = new Vector3(
						1.5f * x, 
						y, 
						Mathf.Sqrt(3f) * (z + 0.5f * x)
					);

					Vector3[] basePoints = GetHexPoints(center, 1.0f, -0.5f);
					Vector3[] topPoints = GetHexPoints(center, 1.0f, 0.5f);

					if (IsAir(x, y + 1, z, data, coordinates, registry, chunkSize))
						AddCap(topPoints, true, voxelColor, result);
					if (IsAir(x, y - 1, z, data, coordinates, registry, chunkSize))
						AddCap(basePoints, false, voxelColor, result);

					for (int i = 0; i < 6; i++)
					{
						Vector3I offset = VoxelConstants.Hexagon.FACE_TO_NEIGHBOR[i];
						if (IsAir(x + offset.X, y + offset.Y, z + offset.Z, data, coordinates, registry, chunkSize))
						{
							int next = (i + 1) % 6;
							Vector3 normal = (basePoints[i] + basePoints[next] - (center * 2.0f)).Normalized();
							normal.Y = 0f;
							AddSide(
								basePoints[i], basePoints[next], topPoints[next], topPoints[i], normal, voxelColor, result
							);
						}
					}
				}
			}
		}
		return result;
	}
	
	public static VoxelEngineVoxel.GeometryData CalculateTexturedChunkGeometry(
		byte[] data, 
		Vector3I coordinates, 
		Dictionary<Vector3I, byte[]> registry, 
		int chunkSize)
	{
		var result = new VoxelEngineVoxel.GeometryData(chunkSize * chunkSize * chunkSize * 18);

		for (int x = 0; x < chunkSize; x++)
		{
			for (int y = 0; y < chunkSize; y++)
			{
				for (int z = 0; z < chunkSize; z++)
				{
					int index = VoxelEngineVoxel.GetIndex(x, y, z, chunkSize);
					byte blockId = data[index];
					if (blockId == 0) continue;

					int texId = VoxelConstants.BLOCK_TO_TEXTURE_INDEX.GetValueOrDefault<VoxelEngineEnums.BlockType, int>((VoxelEngineEnums.BlockType)blockId, 0);
					Vector3 center = new Vector3(1.5f * x, y, Mathf.Sqrt(3f) * (z + 0.5f * x));
					Vector3[] basePoints = GetHexPoints(center, 1.0f, -0.5f);
					Vector3[] topPoints = GetHexPoints(center, 1.0f, 0.5f);

					if (IsAir(x, y + 1, z, data, coordinates, registry, chunkSize))
						AddTexturedCap(topPoints, true, texId, result);
					if (IsAir(x, y - 1, z, data, coordinates, registry, chunkSize))
						AddTexturedCap(basePoints, false, texId, result);

					for (int i = 0; i < 6; i++)
					{
						Vector3I offset = VoxelConstants.Hexagon.FACE_TO_NEIGHBOR[i];
						if (IsAir(x + offset.X, y + offset.Y, z + offset.Z, data, coordinates, registry, chunkSize))
						{
							int nextIdx = (i + 1) % 6;
							Vector3 normal = (basePoints[i] + basePoints[nextIdx] - (center * 2.0f)).Normalized();
							AddTexturedSide(basePoints[i], basePoints[nextIdx], topPoints[nextIdx], topPoints[i], normal, texId, result);
						}
					}
				}
			}
		}
		return result;
	}
	
	public static VoxelEngineVoxel.GeometryData GetVoxelGeometry(int blockType)
	{
		var result = new VoxelEngineVoxel.GeometryData(18);
		int texIndex = VoxelConstants.BLOCK_TO_TEXTURE_INDEX.GetValueOrDefault<VoxelEngineEnums.BlockType, int>((VoxelEngineEnums.BlockType)blockType, 0);
		
		Vector3 center = Vector3.Zero;
		Vector3[] basePoints = GetHexPoints(center, 1.0f, -0.5f);
		Vector3[] topPoints = GetHexPoints(center, 1.0f, 0.5f);

		AddTexturedCap(topPoints, true, texIndex, result);
		AddTexturedCap(basePoints, false, texIndex, result);
		
		for (int i = 0; i < 6; i++)
		{
			int next = (i + 1) % 6;
			Vector3 normal = (basePoints[i] + basePoints[next] - (center * 2.0f)).Normalized();
			normal.Y = 0f;
			AddTexturedSide(basePoints[i], basePoints[next], topPoints[next], topPoints[i], normal, texIndex, result);
		}
		return result;
	}
	
	public static VoxelEngineVoxel.GeometryData GetTexturedVoxelGeometry(int blockType)
	{
		var result = new VoxelEngineVoxel.GeometryData(18);
		int texId = VoxelConstants.BLOCK_TO_TEXTURE_INDEX.GetValueOrDefault<VoxelEngineEnums.BlockType, int>((VoxelEngineEnums.BlockType)blockType, 0);
		Vector3 center = Vector3.Zero;
		Vector3[] basePoints = GetHexPoints(center, 1.0f, -0.5f);
		Vector3[] topPoints = GetHexPoints(center, 1.0f, 0.5f);

		AddTexturedCap(topPoints, true, texId, result);
		AddTexturedCap(basePoints, false, texId, result);

		for (int i = 0; i < 6; i++)
		{
			int nextIdx = (i + 1) % 6;
			Vector3 normal = (basePoints[i] + basePoints[nextIdx] - (center * 2.0f)).Normalized();
			normal.Y = 0f;
			AddTexturedSide(basePoints[i], basePoints[nextIdx], topPoints[nextIdx], topPoints[i], normal, texId, result);
		}
		return result;
	}
	
	private static bool IsAir(int x, int y, int z, byte[] localData, Vector3I coords, Dictionary<Vector3I, byte[]> registry, int size)
	{
		int chunkOffsetX = Mathf.FloorToInt((float)x / size);
		int chunkOffsetY = Mathf.FloorToInt((float)y / size);
		int chunkOffsetZ = Mathf.FloorToInt((float)z / size);

		if (chunkOffsetX == 0 && chunkOffsetY == 0 && chunkOffsetZ == 0)
		{
			// Add a safety clamp here just in case
			int idx = VoxelEngineVoxel.GetIndex(x, y, z, size);
			if (idx < 0 || idx >= localData.Length) return true;
			return localData[idx] == 0;
		}

		Vector3I neighborCoords = new Vector3I(
			coords.X + chunkOffsetX,
			coords.Y + chunkOffsetY,
			coords.Z + chunkOffsetZ
		);

		if (registry.TryGetValue(neighborCoords, out byte[] chunk))
		{
			int nx = ((x % size) + size) % size;
			int ny = ((y % size) + size) % size;
			int nz = ((z % size) + size) % size;
			
			int idx = VoxelEngineVoxel.GetIndex(nx, ny, nz, size);
			if (idx < 0 || idx >= chunk.Length) return true;
			return chunk[idx] == 0;
		}

		return true;
	}
	
	private static Vector3[] GetHexPoints(Vector3 center, float scale, float yOffset)
	{
		Vector3[] points = new Vector3[6];
		// Use an apothem-corrected radius if you want them to touch perfectly
		float radius = scale * (Mathf.Sqrt(3f) / 2f); 
		
		for (int i = 0; i < 6; i++)
		{
			float angle = Mathf.DegToRad(60.0f * i + 30.0f); 
			points[i] = center + new Vector3(Mathf.Cos(angle) * radius, yOffset, Mathf.Sin(angle) * radius);
		}
		return points;
	}
	
	private static void AddSide(
		Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4, 
		Vector3 normal, Color color, VoxelEngineVoxel.GeometryData res)
	{
		VoxelEngineVoxel.AddTriangle(
			p1, p2, p3, normal, color, res.Vertices, res.Normals, res.Colors
		);
		VoxelEngineVoxel.AddTriangle(
			p1, p3, p4, normal, color, res.Vertices, res.Normals, res.Colors
		);
	}
	
	private static void AddTexturedSide(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4, Vector3 normal, int texIndex, VoxelEngineVoxel.GeometryData res)
	{
		var map = VoxelConstants.Hexagon.UvMap["SIDE"]; 
		VoxelEngineVoxel.AddTexturedTriangle(p1, p2, p3, map[0], map[1], map[2], normal, texIndex, res);
		VoxelEngineVoxel.AddTexturedTriangle(p1, p3, p4, map[0], map[2], map[3], normal, texIndex, res);
	}
	
	private static void AddCap(
		Vector3[] points, bool isTop, Color color, VoxelEngineVoxel.GeometryData res
	)
	{
		Vector3 center = Vector3.Zero;
		foreach (var p in points) center += p;
		center /= 6.0f;

		Vector3 normal = isTop ? Vector3.Up : Vector3.Down;
		for (int i = 0; i < 6; i++)
		{
			int next = (i + 1) % 6;
			if (isTop)
				VoxelEngineVoxel.AddTriangle(
					center, points[i], points[next], normal, color, res.Vertices, res.Normals, res.Colors
				);
			else
				VoxelEngineVoxel.AddTriangle(
					center, points[next], points[i], normal, color, res.Vertices, res.Normals, res.Colors
				);
		}
	}
	
	private static void AddTexturedCap(Vector3[] points, bool isTop, int texIndex, VoxelEngineVoxel.GeometryData res)
	{
		Vector3 center = Vector3.Zero;
		foreach (var p in points) center += p;
		center /= 6.0f;

		Vector3 normal = isTop ? Vector3.Up : Vector3.Down;
		var map = VoxelConstants.Hexagon.UvMap[isTop ? "TOP" : "BOTTOM"];

		float cx = VoxelConstants.Hexagon.PixelCenterX / 512.0f;
		float cy = (VoxelConstants.Hexagon.PixelCenterY + (isTop ? (-32.0f - VoxelConstants.Hexagon.Apothem) : (32.0f + VoxelConstants.Hexagon.Apothem))) / 512.0f;
		Vector2 uvCenter = new Vector2(cx, cy);

		for (int i = 0; i < 6; i++)
		{
			int next = (i + 1) % 6;
			if (isTop)
				VoxelEngineVoxel.AddTexturedTriangle(center, points[i], points[next], uvCenter, map[i], map[next], normal, texIndex, res);
			else
				VoxelEngineVoxel.AddTexturedTriangle(center, points[next], points[i], uvCenter, map[next], map[i], normal, texIndex, res);
		}
	}
	
	public static int NormalToHexDirection(Vector3 normal)
	{
		Vector3I[] directions = VoxelConstants.Hexagon.FACE_TO_NEIGHBOR;
		int bestIndex = 0;
		float bestDot = float.MinValue;

		for (int i = 0; i < 6; i++)
		{
			Vector3 direction = new Vector3(directions[i].X, directions[i].Y, directions[i].Z).Normalized();
			float dot = normal.Normalized().Dot(direction);

			if (dot > bestDot)
			{
				bestDot = dot;
				bestIndex = i;
			}
		}
		return bestIndex;
	}
	
	private static Vector3 GetHexWorldPosition(Vector3I position, float scale, float height)
	{
		return new Vector3(
			scale * (1.5f * position.X),
			position.Y * height,
			scale * (Mathf.Sqrt(3.0f) * (position.Z + 0.5f * position.X))
		);
	}
	
	public static Vector3I WorldToLocal(Vector3 worldPos, Vector3 chunkOrigin)
	{
		Vector3 rel = worldPos - chunkOrigin;
		float q = rel.X / 1.5f;
		float r = (rel.Z / Mathf.Sqrt(3.0f)) - (0.5f * q);
		
		// Cube rounding logic to snap to hexagonal grid
		float x = q, z = r, y = -x - z;
		int rx = (int)Mathf.Round(x), ry = (int)Mathf.Round(y), rz = (int)Mathf.Round(z);
		
		float dx = Math.Abs(rx - x), dy = Math.Abs(ry - y), dz = Math.Abs(rz - z);
		if (dx > dy && dx > dz) rx = -ry - rz;
		else if (dy > dz) ry = -rx - rz;
		else rz = -rx - ry;
		
		return new Vector3I(rx, (int)Mathf.Round(rel.Y), rz);
	}
	
	public static Vector3I WorldToChunk(Vector3 worldPosition, int chunkSize)
	{
		float q = (2.0f / 3.0f) * worldPosition.X;
		float r = ((-1.0f / 3.0f) * worldPosition.X + (worldPosition.Z / Mathf.Sqrt(3.0f)));
		
		return new Vector3I(
			Mathf.FloorToInt(q / chunkSize),
			0,
			Mathf.FloorToInt(r / chunkSize)
		);
	}
	
	public static Vector3 ChunkToWorld(Vector3I coordinate, int size)
	{
		return GetHexWorldPosition(
			new Vector3I(
				coordinate.X * size, 
				coordinate.Y * size,
				coordinate.Z * size
			), 
			1.0f, 
			1.0f
		);
	}
	
	public static Vector3I VoxelToChunk(Vector3I voxel, int chunkSize)
	{
		return new Vector3I(
			Mathf.FloorToInt((float)voxel.X / chunkSize),
			Mathf.FloorToInt((float)voxel.Y / chunkSize),
			Mathf.FloorToInt((float)voxel.Z / chunkSize)
		);
	}
	
	public static Vector3 VoxelToWorld(Vector3I voxel, Vector3 chunkOrigin)
	{
		return GetHexWorldPosition(voxel, 1.0f, 1.0f) + chunkOrigin;
	}
}
