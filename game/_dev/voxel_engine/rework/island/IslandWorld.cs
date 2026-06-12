using Godot;

public class IslandWorld : IWorldProvider
{
	public float[] Heightmap;
	public Vector2I WorldSize;
	public int MaxHeight;

	public void Generate(Vector2I worldSize, int seed, int maxHeight)
	{
		WorldSize = worldSize;
		MaxHeight = maxHeight;

		Heightmap = new float[worldSize.X * worldSize.Y];

		var field = IslandFieldGenerator.GenerateIslandField(
			new Vector2I(20, 20),
			seed,
			0.08f
		);

		foreach (var kv in field)
		{
			int worldSeed =
				kv.Value.Seed ^
				seed;

			float[] island = IslandBlueprint.GenerateDockIsland(
				worldSize,
				worldSeed,
				kv.Value.Flatness,
				maxHeight,
				kv.Value.Scale
			);

			for (int i = 0; i < Heightmap.Length; i++)
			{
				Heightmap[i] = Mathf.Max(Heightmap[i], island[i]);
			}
		}

		Normalize();
	}

	public float SampleHeight(int x, int z)
	{
		if (x < 0 || z < 0 || x >= WorldSize.X || z >= WorldSize.Y)
			return 0;

		return Heightmap[x + z * WorldSize.X];
	}

	private void Normalize()
	{
		float min = float.MaxValue;
		float max = float.MinValue;

		for (int i = 0; i < Heightmap.Length; i++)
		{
			min = Mathf.Min(min, Heightmap[i]);
			max = Mathf.Max(max, Heightmap[i]);
		}

		float range = max - min;
		if (range <= 0) return;

		for (int i = 0; i < Heightmap.Length; i++)
			Heightmap[i] = (Heightmap[i] - min) / range;
	}
	
	private void GenerateIslandChunk(Vector3 position, ChunkData chunkData)
	{
		int size = chunkData.GetSize();

		int baseX = (int)position.X;
		int baseZ = (int)position.Z;

		var world = Terrain.Instance.World;

		for (int x = 0; x < size; x++)
		for (int z = 0; z < size; z++)
		{
			int wx = baseX + x;
			int wz = baseZ + z;

			float h = world.Sample(wx, wz);
			int height = Mathf.FloorToInt(h);

			for (int y = 0; y < height; y++)
			{
				if (y < world.MaxHeight * 0.2f) continue;

				chunkData.AddVoxel(x, y, z, Voxel.STONE);
			}
		}
	}
}
