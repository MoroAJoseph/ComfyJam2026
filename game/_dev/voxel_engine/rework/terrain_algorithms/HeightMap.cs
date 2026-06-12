using Godot;

[GlobalClass]
public partial class HeightMap : TerrainNoise
{
	public HeightMap()
	{
		Name = "HeightMap";
	}

	public override int GetHeight(Vector2 position, int maxHeight)
	{
		float noise1 = Noise.GetNoise2D(position.X, position.Y);
		float noise2 = Noise.GetNoise2D(position.X * 2, position.Y * 2);
		float noise3 = Noise.GetNoise2D(position.X * 4, position.Y * 4);

		float rand = ((noise1 + 0.5f * noise2 + 0.25f * noise3) / 1.75f + 1.0f) / 2.0f;
		float randP = Mathf.Pow(rand, 2.1f);

		return (int)(maxHeight * randP);
	}
}
