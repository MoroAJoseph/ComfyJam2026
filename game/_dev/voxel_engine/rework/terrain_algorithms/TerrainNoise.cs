using Godot;

[GlobalClass]
public partial class TerrainNoise : Resource
{
	[Export] public FastNoiseLite Noise = new FastNoiseLite();
	public string Name { get; protected set; } = "NoiseBase";

	public virtual int GetHeight(Vector2 position, int maxHeight) 
	{ 
		return 0; 
	}

	public virtual bool HasVoxel(Vector3 position) => false;
}
