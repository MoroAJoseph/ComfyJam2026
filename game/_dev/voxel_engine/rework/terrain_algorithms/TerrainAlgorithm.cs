using Godot;

public interface IWorldProvider
{
	float SampleHeight(int x, int z);
	int MaxHeight { get; }
}

public partial class TerrainAlgorithm : Resource
{
	[Export] public int MaxHeight;
	[Export] public TerrainNoise Noise;

	public string Name { get; protected set; } = "noName";

	public override void GenerateData(
		Vector3 position,
		Noise biomeNoiseInput,
		ChunkData chunkData,
		GodotObject geometry = null)
	{
		if (Terrain.Instance.Mode != Terrain.TerrainMode.IslandWorld)
		{
			GenerateNoiseChunk(position, chunkData, biomeNoiseInput);
			return;
		}

		var world = Terrain.Instance.World;

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
				if (y < world.MaxHeight * 0.2f)
					continue;

				chunkData.AddVoxel(x, y, z, Voxel.STONE);
			}
		}
	}

	public virtual string CreateName() 
	{ 
		return Name; 
	}
}
