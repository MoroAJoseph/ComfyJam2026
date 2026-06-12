using Godot;
using System.Collections.Generic;

public partial class Terrain : Node3D
{
	public enum TerrainMode
	{
		ChunkNoise,
		IslandWorld
	}
	public static Terrain Instance { get; private set; }

	[Export] public TerrainMode Mode = TerrainMode.ChunkNoise;
	[Export] public bool Wireframe = false;
	[Export] public Vector3I Dimensions = new Vector3I(128, 64, 128);
	[Export] public Godot.Collections.Dictionary<Voxel, Color> ColorArray;
	[Export] public PackedScene ChunkScene;
	[Export] public MeshingAlgorithm MeshingAlgorithm;
	[Export] public TerrainAlgorithm TerrainAlgorithm;

	public ChunkManager Manager;
	public IWorldProvider TerrainWorld;
	
	public override void _EnterTree() => Instance = this;

	public override void _Ready()
	{
		SetWireframe(Wireframe);

		Manager = new ChunkManager
		{
			Name = "ChunkManager",
			ChunkScene = ChunkScene,
			ChunkSize = 16,
			MeshingAlgorithm = MeshingAlgorithm,
			TerrainAlgorithm = TerrainAlgorithm
		};

		AddChild(Manager);

		MeshingAlgorithm.SetColors(ColorArray);

		if (Mode == TerrainMode.IslandWorld)
		{
			TerrainWorld = new IslandWorld();

			TerrainWorld.Generate(
				new Vector2I(Dimensions.X, Dimensions.Z),
				seed: 1337,
				maxHeight: Dimensions.Y,
				seaLevel: 0.2f
			);

			Manager.TerrainAlgorithm = new IslandTerrain();
		}

		GenerateChunks(Vector3I.Zero);
	}

	public void SetWireframe(bool enabled)
	{
		Wireframe = enabled;
		GetViewport().DebugDraw = enabled ? Viewport.DebugDrawEnum.Wireframe : Viewport.DebugDrawEnum.Disabled;
	}

	private void GenerateChunks(Vector3I baseGridOffset)
	{
		// Calculate bounds based on the integer size
		int size = Manager.ChunkSize;
		Vector3I numberOfChunks = new Vector3I(
			Mathf.CeilToInt(Dimensions.X / (float)size),
			Mathf.CeilToInt(Dimensions.Y / (float)size),
			Mathf.CeilToInt(Dimensions.Z / (float)size)
		);

		for (int x = 0; x < numberOfChunks.X; x++)
		{
			for (int z = 0; z < numberOfChunks.Z; z++)
			{
				for (int y = 0; y < numberOfChunks.Y; y++)
				{
					Vector3I chunkGridIndex = new Vector3I(x, y, z) + baseGridOffset;
					Manager.GenerateChunk(chunkGridIndex);
				}
			}
		}
	}
}
