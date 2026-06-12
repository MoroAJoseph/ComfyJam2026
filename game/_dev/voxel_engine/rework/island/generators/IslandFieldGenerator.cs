using Godot;
using System.Collections.Generic;

public static class IslandFieldGenerator
{
	public struct IslandCell
	{
		public int Seed;
		public float Flatness;
		public float Scale;
	}

	public static Dictionary<Vector2I, IslandCell> GenerateIslandField(
		Vector2I worldSize,
		int seed,
		float density)
	{
		var field = new Dictionary<Vector2I, IslandCell>();

		for (int x = 0; x < worldSize.X; x++)
		for (int z = 0; z < worldSize.Y; z++)
		{
			ulong cellSeed = (ulong)(seed ^ (x * 73856093) ^ (z * 19349663));

			var rng = new RandomNumberGenerator();
			rng.Seed = cellSeed;

			if (rng.Randf() > density)
				continue;

			field[new Vector2I(x, z)] = new IslandCell
			{
				Seed = unchecked((int)rng.Randi()),
				Flatness = rng.RandfRange(0.3f, 0.9f),
				Scale = rng.RandfRange(0.8f, 1.3f)
			};
		}

		return field;
	}
}
