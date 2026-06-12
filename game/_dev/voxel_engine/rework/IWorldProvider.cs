using Godot;

public interface IWorldProvider
{
	int MaxHeight { get; }
	float SeaLevel { get; }

	void Generate(Vector2I worldSize, int seed, int maxHeight, float seaLevel);

	float SampleHeight(int x, int z);
}
