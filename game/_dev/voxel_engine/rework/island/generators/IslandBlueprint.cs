using Godot;

public static class IslandBlueprint
{
	public static float[] GenerateDockIsland(
		Vector2I dims,
		int seed,
		float flatness,
		int maxHeight,
		float scale)
	{
		int size = dims.X * dims.Y;
		float[] map = new float[size];

		var rng = new RandomNumberGenerator();
		rng.Seed = (ulong)seed;

		AddSlopedBackbone(map, dims, rng.RandfRange(0.3f, 0.9f));

		int blobCount = rng.RandiRange(1, 3);
		for (int i = 0; i < blobCount; i++)
		{
			AddGaussianBlob(
				map,
				dims,
				new Vector2(rng.Randf() * dims.X, rng.Randf() * dims.Y),
				rng.RandfRange(2.0f, 5.0f)
			);
		}

		ApplyEdgeMask(map, dims);
		ApplyFlattening(map, flatness);
		ApplyNoiseWarp(map, dims, seed, rng.RandfRange(0.02f, 0.08f));

		Normalize(map);

		for (int i = 0; i < map.Length; i++)
		{
			map[i] = Mathf.Clamp(map[i], 0f, 1f);
			map[i] *= maxHeight * scale;
		}

		return map;
	}

	private static void AddSlopedBackbone(float[] map, Vector2I dims, float angle)
	{
		Vector2 center = new Vector2(dims.X, dims.Y) * 0.5f;
		float maxDist = Mathf.Min(dims.X, dims.Y) * 0.45f;

		for (int x = 0; x < dims.X; x++)
		for (int y = 0; y < dims.Y; y++)
		{
			float d = new Vector2(x, y).DistanceTo(center);
			float falloff = Mathf.Clamp(1f - (d / maxDist), 0f, 1f);
			map[x + y * dims.X] = Mathf.Pow(falloff, angle) * 8f;
		}
	}

	private static void AddGaussianBlob(float[] map, Vector2I dims, Vector2 pos, float strength)
	{
		float radius = dims.X * 0.25f;

		for (int x = 0; x < dims.X; x++)
		for (int y = 0; y < dims.Y; y++)
		{
			float d = new Vector2(x, y).DistanceTo(pos);
			if (d < radius)
			{
				float v = Mathf.Exp(-(d * d) / (2f * Mathf.Pow(radius * 0.5f, 2f)));
				map[x + y * dims.X] += v * strength;
			}
		}
	}

	private static void ApplyFlattening(float[] map, float flatness)
	{
		float target = 4f;

		for (int i = 0; i < map.Length; i++)
			if (map[i] > target)
				map[i] = Mathf.Lerp(map[i], target, flatness);
	}

	private static void ApplyEdgeMask(float[] map, Vector2I dims)
	{
		Vector2 center = new Vector2(dims.X, dims.Y) * 0.5f;
		float maxDist = Mathf.Min(dims.X, dims.Y) * 0.45f;

		for (int x = 0; x < dims.X; x++)
		for (int y = 0; y < dims.Y; y++)
		{
			float d = new Vector2(x, y).DistanceTo(center);

			if (d > maxDist)
			{
				float fade = Mathf.Clamp(
					1f - ((d - maxDist) / (Mathf.Min(dims.X, dims.Y) * 0.05f)),
					0f, 1f
				);

				map[x + y * dims.X] *= fade;
			}
		}
	}

	private static void Normalize(float[] map)
	{
		float min = float.MaxValue;
		float max = float.MinValue;

		for (int i = 0; i < map.Length; i++)
		{
			min = Mathf.Min(min, map[i]);
			max = Mathf.Max(max, map[i]);
		}

		float range = max - min;
		if (range <= 0f) return;

		for (int i = 0; i < map.Length; i++)
			map[i] = (map[i] - min) / range;
	}

	private static void ApplyNoiseWarp(float[] map, Vector2I dims, int seed, float freq)
	{
		var noise = new FastNoiseLite();
		noise.Seed = seed;
		noise.Frequency = freq;

		for (int x = 0; x < dims.X; x++)
		for (int y = 0; y < dims.Y; y++)
		{
			int i = x + y * dims.X;
			map[i] += noise.GetNoise2D(x * 8f, y * 8f) * 0.35f;
		}
	}
}
