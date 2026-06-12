using Godot;

public partial class TerrainAlgorithm : Resource
{
	[Export] public int MaxHeight;
	[Export] public TerrainNoise Noise;

	public string Name { get; protected set; } = "noName";

	public virtual void GenerateData(
		Vector3 position,
		Noise biomeNoiseInput,
		ChunkData chunkData,
		GodotObject geometry = null)
	{
		if (Terrain.Instance.Mode == Terrain.TerrainMode.IslandWorld)
		{
			GenerateIslandChunk(position, chunkData);
		}
		else
		{
			GenerateNoiseChunk(position, chunkData, biomeNoiseInput);
		}
	}

	protected virtual void GenerateIslandChunk(Vector3 position, ChunkData chunkData)
	{
		// implemented in IslandTerrain OR via world sampling
	}

	protected virtual void GenerateNoiseChunk(Vector3 position, ChunkData chunkData, Noise noise)
	{
		// existing noise terrain logic
	}

	public virtual string CreateName()
	{
		return Name;
	}
}
