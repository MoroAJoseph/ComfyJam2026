using Godot;
using System.Collections.Generic;

[GlobalClass]
public partial class IslandTerrain : TerrainAlgorithm
{
	[Export] public float seaLevel = 8f;

	public override void GenerateData(
		Vector3 position,
		Noise biomeNoiseInput,
		ChunkData chunkData,
		GodotObject geometry = null)
	{
		int size = chunkData.GetSize();

		int baseX = (int)position.X;
		int baseZ = (int)position.Z;

		var world = IslandWorld.Instance;

		for (int x = 0; x < size; x++)
		for (int z = 0; z < size; z++)
		{
			int worldX = baseX + x;
			int worldZ = baseZ + z;

			float h = world.Sample(worldX, worldZ);

			int height = Mathf.FloorToInt(h);

			for (int y = 0; y < height; y++)
			{
				if (y < world.SeaLevel)
					continue;

				chunkData.AddVoxel(x, y, z, Voxel.STONE);
			}
		}
	}

	private void Normalize(float[] map)
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
	
	private void ClampMap(float[] map)
	{
		for (int i = 0; i < map.Length; i++)
		{
			map[i] = Mathf.Clamp(map[i], 0f, 1.5f);
		}
	}
	
	private void DebugHeightmap(float[] map)
	{
		float min = float.MaxValue;
		float max = float.MinValue;

		for (int i = 0; i < map.Length; i++)
		{
			min = Mathf.Min(min, map[i]);
			max = Mathf.Max(max, map[i]);
		}

		GD.Print($"Heightmap Min: {min}, Max: {max}");
	}

}
