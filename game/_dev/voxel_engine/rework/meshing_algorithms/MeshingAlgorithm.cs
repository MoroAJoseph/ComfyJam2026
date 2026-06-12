using Godot;

[GlobalClass]
public abstract partial class MeshingAlgorithm : Resource
{
	public string Name = "NoName";

	protected Godot.Collections.Dictionary<ChunkData.Voxel, Color> Colors;

	public IVoxelGeometry Geometry { get; protected set; }

	public void SetColors(
		Godot.Collections.Dictionary<ChunkData.Voxel, Color> colors)
	{
		Colors = colors;
	}
	
	[Export]
	public GodotObject ScriptGeometry 
	{ 
		get => Geometry as GodotObject;
		protected set => Geometry = value as IVoxelGeometry;
	}

	public void SetGeometry(IVoxelGeometry geometry)
	{
		Geometry = geometry;
	}

	public abstract void GenerateMesh(
		ChunkData chunkData,
		MeshData meshData
	);
}
