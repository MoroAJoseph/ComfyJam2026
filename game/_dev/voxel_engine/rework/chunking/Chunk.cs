using Godot;

public partial class Chunk : StaticBody3D
{
	[Export] public ShaderMaterial Mat;
	[Export] public MeshInstance3D MyMeshInstance3D;
	[Export] public CollisionShape3D MyCollisionShape;

	public Noise BiomeNoise = new FastNoiseLite();
	public ChunkData ChunkData = new ChunkData();
	public MeshData MeshData = new MeshData();
	public MeshingAlgorithm MeshingAlgorithm;
	public Vector3 ChunkOrigin = Vector3.Zero;
	public ChunkManager ChunkManager;

	public override void _Ready()
	{
		// Apply the calculated origin to the actual node transform
		this.Position = ChunkOrigin; 
		
		if (MyCollisionShape == null) GD.PrintErr("Assign MyCollisionShape in Inspector!");
		if (MyMeshInstance3D == null) GD.PrintErr("Assign MyMeshInstance3D in Inspector!");
		
		if (Mat != null && MyMeshInstance3D != null)
			MyMeshInstance3D.MaterialOverride = Mat;
	}

	public void GenerateData(TerrainAlgorithm terrainAlgorithm)
	{
		var geometry = MeshingAlgorithm?.ScriptGeometry;
		terrainAlgorithm.GenerateData(ChunkOrigin, BiomeNoise, ChunkData, geometry);
	}

	public void CreateMesh()
	{
		if (MeshingAlgorithm == null) return;
		
		MeshingAlgorithm.GenerateMesh(
			ChunkData,
			MeshData,
			ChunkOrigin,
			ChunkManager
		);
	}

	public void CommitMesh()
	{
		if (MeshData.IsEmpty()) return;

		// Commit the MeshData to prepare the internal arrays
		MeshData.Commit();

		// Create and populate the mesh
		var mesh = new ArrayMesh();
		mesh.AddSurfaceFromArrays(Mesh.PrimitiveType.Triangles, MeshData.GetSurfaceArray());
		
		// Update the visual and physical representation
		if (MyMeshInstance3D != null) MyMeshInstance3D.Mesh = mesh;
		if (MyCollisionShape != null) MyCollisionShape.Shape = mesh.CreateTrimeshShape();
	}

	public void Remesh()
	{
		MeshData.Reset();
		CreateMesh();
		CommitMesh();
	}

	public void RemoveVoxel(Vector3I pos)
	{
		ChunkData.RemoveVoxel(pos.X, pos.Y, pos.Z);
	}
}
