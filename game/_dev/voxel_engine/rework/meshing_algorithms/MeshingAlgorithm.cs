using Godot;

public interface IVoxelDataProvider
{
	Voxel GetVoxelAt(Vector3I globalGridPos);
}

[GlobalClass]
public abstract partial class MeshingAlgorithm : Resource
{
	public string Name = "NoName";
	protected Godot.Collections.Dictionary<Voxel, Color> Colors;
	public IVoxelGeometry Geometry { get; protected set; }

	public void SetColors(Godot.Collections.Dictionary<Voxel, Color> colors) => Colors = colors;
	
	[Export]
	public GodotObject ScriptGeometry 
	{ 
		get => Geometry as GodotObject;
		protected set => Geometry = value as IVoxelGeometry;
	}

	public void SetGeometry(IVoxelGeometry geometry) => Geometry = geometry;

	public abstract void GenerateMesh(
		ChunkData chunkData,
		MeshData meshData,
		Vector3 chunkOrigin,
		IVoxelDataProvider provider
	);
}
