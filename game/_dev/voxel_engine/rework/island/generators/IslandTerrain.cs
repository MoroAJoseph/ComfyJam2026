using Godot;

[GlobalClass]
public partial class IslandTerrain : TerrainAlgorithm
{
	public override void GenerateData(
		Vector3 position,
		Noise biomeNoiseInput,
		ChunkData chunkData,
		GodotObject geometry = null)
	{
		var world = Terrain.Instance.TerrainWorld;
		if (world == null)
			return;

		int size = chunkData.GetSize();

		int baseX = (int)position.X;
		int baseZ = (int)position.Z;

		for (int x = 0; x < size; x++)
		for (int z = 0; z < size; z++)
		{
			int wx = baseX + x;
			int wz = baseZ + z;

			float h = world.SampleHeight(wx, wz);
			int height = Mathf.FloorToInt(h);

			for (int y = 0; y < height; y++)
			{
				if (y < world.SeaLevel)
					continue;

				if (y < height - 3)
					continue;

				chunkData.AddVoxel(x, y, z, Voxel.STONE);
			}
		}
	}
}
