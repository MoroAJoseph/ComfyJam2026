using Godot;

public class IslandWorld : IWorldProvider
{
	public float[] Heightmap;
	public Vector2I WorldSize;

	public int MaxHeight { get; private set; }
	public float SeaLevel { get; private set; }

	public void Generate(Vector2I worldSize, int seed, int maxHeight, float seaLevel)
	{
		WorldSize = worldSize;
		MaxHeight = maxHeight;
		SeaLevel = seaLevel;

		Heightmap = new float[worldSize.X * worldSize.Y];

		var field = IslandFieldGenerator.GenerateIslandField(
			new Vector2I(20, 20),
			seed,
			0.08f
		);

		foreach (var kv in field)
		{
			int worldSeed = kv.Value.Seed ^ seed;

			float[] island = IslandBlueprint.GenerateDockIsland(
				worldSize,
				worldSeed,
				kv.Value.Flatness,
				maxHeight,
				kv.Value.Scale
			);

			for (int i = 0; i < Heightmap.Length; i++)
				Heightmap[i] = Mathf.Max(Heightmap[i], island[i]);
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
}
