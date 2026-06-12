using Godot;

[GlobalClass]
public partial class HeightMapTerrain : TerrainAlgorithm
{
	public HeightMapTerrain()
	{
		Name = "HeightMapTerrain";
		Noise = new HeightMap();
	}

	public override string CreateName()
	{
		return $"{Name}_{Noise.Name}_{MaxHeight}";
	}

	public override void GenerateData(
		Vector3 position,
		Noise biomeNoise,
		ChunkData chunkData,
		GodotObject geometry = null
	)
	{
		int size = chunkData.GetSize();

		int baseX = (int)position.X;
		int baseY = (int)position.Y;
		int baseZ = (int)position.Z;

		float scale = 0.01f;

		for (int x = 0; x < size; x++)
		{
			for (int z = 0; z < size; z++)
			{
				// consistent world sampling
				float worldX = (baseX + x) * scale;
				float worldZ = (baseZ + z) * scale;

				Vector2 samplePos = new Vector2(worldX, worldZ);

				int worldHeight = Noise.GetHeight(samplePos, MaxHeight);

				for (int y = 0; y < size; y++)
				{
					int worldY = baseY + y;

					if (worldY > worldHeight)
						continue;

					float n1 = biomeNoise.GetNoise2D(worldX, worldZ);
					float n2 = biomeNoise.GetNoise2D(worldX * 2f, worldZ * 2f);
					float n3 = biomeNoise.GetNoise2D(worldX * 4f, worldZ * 4f);

					float biomeN =
						((n1 + 0.5f * n2 + 0.25f * n3) / 1.75f + 1f) * 0.5f;

					chunkData.AddVoxel(
						x, y, z,
						DetermineVoxelType(worldY, biomeN)
					);
				}
			}
		}
	}

	private Voxel DetermineVoxelType(int worldY, float biomeN)
	{
		float normalizedY = worldY / (float)MaxHeight;

		Voxel baseVoxel =
			(biomeN < 0.4f) ? Voxel.SAND :
			(biomeN < 0.6f) ? Voxel.GRASS :
			Voxel.STONE;

		if (normalizedY >= 0.22f)
		{
			if (biomeN > 0.5f && normalizedY > 0.4f)
				return Voxel.COBBLESTONE;

			return Voxel.STONE;
		}

		return baseVoxel;
	}
}
