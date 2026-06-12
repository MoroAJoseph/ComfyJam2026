using Godot;
using System;

[GlobalClass]
public partial class BinaryTerrain : TerrainAlgorithm
{
	public BinaryTerrain()
	{
		Name = "BinaryTerrain";
	}

	public override string CreateName()
	{
		return $"{Name}_{Noise.Name}_{MaxHeight}";
	}

	public override void GenerateData(Vector3 position, Noise biomeNoise, ChunkData chunkData, GodotObject geometry = null)
	{
		int chunkSize = chunkData.GetSize();

		for (int x = 0; x < chunkSize; x++)
		{
			for (int z = 0; z < chunkSize; z++)
			{
				// Decoupled world position calculation
				Vector2 worldPosXZ = GetWorldXZ(position, x, z, geometry);
				int height = Noise.GetHeight(worldPosXZ, MaxHeight);

				if (height < position.Y) continue;

				int localHeight = Mathf.Min(height - (int)position.Y, chunkSize);
				for (int y = 0; y < localHeight; y++)
				{
					// Binary terrain defaults to Grass
					chunkData.AddVoxel(x, y, z, Voxel.GRASS);
				}
			}
		}
	}

	private Vector2 GetWorldXZ(Vector3 chunkPos, int x, int z, GodotObject geometry)
	{
		if (geometry != null && geometry.HasMethod("get_world_position"))
		{
			Vector3 pos = (Vector3)geometry.Call("get_world_position", new Vector3I(x, 0, z));
			return new Vector2(chunkPos.X + pos.X, chunkPos.Z + pos.Z);
		}
		return new Vector2(chunkPos.X + x, chunkPos.Z + z);
	}
}
