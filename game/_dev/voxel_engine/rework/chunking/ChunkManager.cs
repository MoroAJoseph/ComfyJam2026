using Godot;
using System.Collections.Generic;
using System.Threading.Tasks;

public partial class ChunkManager : Node, IVoxelDataProvider
{
	[Export] public PackedScene ChunkScene;
	[Export] public int ChunkSize;
	[Export] public MeshingAlgorithm MeshingAlgorithm;
	[Export] public TerrainAlgorithm TerrainAlgorithm;
	
	private readonly object _chunkLock = new object();
	private Dictionary<Vector3I, Chunk> _chunks = new Dictionary<Vector3I, Chunk>();

	public void GenerateChunk(Vector3I chunkGridIndex)
	{
		Callable.From(() => {
			Chunk chunk = (Chunk)ChunkScene.Instantiate();
			chunk.ChunkData.SetSize(ChunkSize);
			chunk.MeshingAlgorithm = MeshingAlgorithm;
			chunk.ChunkOrigin = GetChunkWorldOrigin(chunkGridIndex);
			chunk.ChunkManager = this;
			if (chunkGridIndex == Vector3I.Zero)
			{
			}
			lock (_chunkLock) { _chunks[chunkGridIndex] = chunk; }
			
			Task.Run(() => {
				chunk.GenerateData(TerrainAlgorithm);
				
				Callable.From(() => {
					if (!chunk.ChunkData.IsEmpty()) {
						chunk.CreateMesh();
						chunk.CommitMesh();
						AddChild(chunk);
					} else {
						chunk.QueueFree();
					}
				}).CallDeferred();
			});
		}).CallDeferred();
	}

	public Voxel GetVoxelAt(Vector3I globalGridPos) => Voxel.AIR;

	public Chunk GetChunk(Vector3I pos)
	{
		Vector3I chunkPos = VoxelToChunkPosition(pos);
		lock (_chunkLock) { return _chunks.TryGetValue(chunkPos, out Chunk chunk) ? chunk : null; }
	}

	private Vector3 GetChunkWorldOrigin(Vector3I chunkGridIndex)
	{
		var geom = (IVoxelGeometry)MeshingAlgorithm.ScriptGeometry;
		return geom.GetChunkWorldOrigin(chunkGridIndex, ChunkSize);
	}

	private Vector3I VoxelToChunkPosition(Vector3I pos)
	{
		return new Vector3I(
			Mathf.FloorToInt((float)pos.X / ChunkSize),
			Mathf.FloorToInt((float)pos.Y / ChunkSize),
			Mathf.FloorToInt((float)pos.Z / ChunkSize)
		);
	}

	private Vector3I GlobalToLocal(Vector3I pos)
	{
		Vector3I chunkIndex = VoxelToChunkPosition(pos);

		Vector3I chunkBase = new Vector3I(
			chunkIndex.X * ChunkSize,
			chunkIndex.Y * ChunkSize,
			chunkIndex.Z * ChunkSize
		);

		return pos - chunkBase;
	}
}
