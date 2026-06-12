using Godot;
using System;

[GlobalClass]
public partial class Terrain3D : TerrainAlgorithm
{
	public Terrain3D()
	{
		Name = "Terrain3D";
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
				for (int y = 0; y < chunkSize; y++)
				{
					Vector3 worldPos = GetWorldPos(position, x, y, z, geometry);
					
					if (!Noise.HasVoxel(worldPos)) continue;

					// Biome calculation using the same layered noise logic
					float n1 = biomeNoise.GetNoise2D(worldPos.X, worldPos.Z);
					float n2 = biomeNoise.GetNoise2D(2 * worldPos.X, 2 * worldPos.Z);
					float n3 = biomeNoise.GetNoise2D(4 * worldPos.X, 4 * worldPos.Z);
					
					float biomeN = ((n1 + 0.5f * n2 + 0.25f * n3) / 1.75f + 1.0f) / 2.0f;
					
					Voxel biome = Voxel.SAND;
					if (biomeN > 0.55f) biome = Voxel.GRASS;
					
					float normalizedY = (y + position.Y) / MaxHeight;
					if (normalizedY >= 0.22f)
					{
						biome = Voxel.STONE;
						if (biomeN > 0.5f && normalizedY > 0.4f) biome = Voxel.COBBLESTONE;
					}
					
					chunkData.AddVoxel(x, y, z, biome);
				}
			}
		}
	}

	private Vector3 GetWorldPos(Vector3 chunkPos, int x, int y, int z, GodotObject geometry)
	{
		if (geometry != null && geometry.HasMethod("get_world_position"))
		{
			Vector3 pos = (Vector3)geometry.Call("get_world_position", new Vector3I(x, y, z));
			return chunkPos + pos;
		}
		return chunkPos + new Vector3(x, y, z);
	}
}
