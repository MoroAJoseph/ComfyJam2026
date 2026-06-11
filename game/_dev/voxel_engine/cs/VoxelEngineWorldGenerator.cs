using Godot;
using Godot.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;

[GlobalClass]
public partial class VoxelEngineWorldGenerator : Node3D
{
	[ExportGroup("Generation Settings")]
	[Export] public bool UseHexagons { get; set; } = false;
	[Export] public bool UseCollision { get; set; } = false;
	[Export] public int ChunkSize { get; set; } = 64;
	[Export] public int GenerationHeight { get; set; } = 16;
	[Export] public int GenerationRadius { get; set; } = 5;
	[Export] public int RenderRadius { get; set; } = 5;

	[ExportGroup("Terran Settings")]
	[Export] public FastNoiseLite Noise { get; set; }
	[Export] public int NoiseSeed { get; set; } = 0;
	[Export] public Color[] VoxelColors = new Color[] 
	{ 
		Godot.Colors.Red, 
		Godot.Colors.Blue, 
		Godot.Colors.Green, 
		Godot.Colors.Yellow 
	};
	[Export] public int SeaLevel { get; set; } = 8;

	// Internal state
	private Godot.Collections.Dictionary<Vector3I, byte[]> _chunksData = new();
	private System.Collections.Generic.Dictionary<Vector3I, ChunkData> _activeChunks = new();
	private bool _dataInitialized = false;

	private struct ChunkData
	{
		public Rid MeshRid, InstanceRid;
		public ChunkData(Rid mesh, Rid instance) { MeshRid = mesh; InstanceRid = instance; }
	}

	public Godot.Collections.Dictionary<Vector3I, byte[]> GetChunksData() => _chunksData;
	
	public void GenerateWorldData()
	{
		Noise.Seed = NoiseSeed;
		int verticalChunkCount = Mathf.CeilToInt((float)GenerationHeight / ChunkSize);
		
		for (int x = -GenerationRadius; x <= GenerationRadius; x++)
		{
			for (int z = -GenerationRadius; z <= GenerationRadius; z++)
			{
				if (new Vector2(x, z).Length() <= GenerationRadius)
				{
					for (int y = 0; y < verticalChunkCount; y++)
					{
						var coord = new Vector3I(x, y, z);
						Vector3 origin = VoxelEngineHexagon.ChunkToWorld(coord, ChunkSize);
						_chunksData[coord] = GenerateRawVoxels(origin);
					}
				}
			}
		}
	}

	private byte[] GenerateRawVoxels(Vector3 origin)
	{
		byte[] voxels = new byte[ChunkSize * ChunkSize * ChunkSize];
		var localNoise = (FastNoiseLite)Noise.Duplicate(); 
		localNoise.Seed = NoiseSeed;

		for (int x = 0; x < ChunkSize; x++)
		for (int z = 0; z < ChunkSize; z++)
		{
			Vector3 worldPosXZ = origin + VoxelEngineHexagon.VoxelToWorld(new Vector3I(x, 0, z), Vector3.Zero);
			float baseHeight = localNoise.GetNoise2D(worldPosXZ.X * 0.005f, worldPosXZ.Z * 0.005f) * GenerationHeight;

			for (int y = 0; y < ChunkSize; y++)
			{
				Vector3 worldPos = origin + VoxelEngineHexagon.VoxelToWorld(new Vector3I(x, y, z), Vector3.Zero);
				float density = baseHeight - worldPos.Y;
				float caveNoise = localNoise.GetNoise3D(worldPos.X * 0.05f, worldPos.Y * 0.05f, worldPos.Z * 0.05f);

				if (density + (caveNoise * 5.0f) > 0.0f)
				{
					byte blockType = (byte)VoxelEngineEnums.BlockType.Cobblestone;
					if (worldPos.Y < baseHeight - 3) blockType = (byte)VoxelEngineEnums.BlockType.Stone;
					else if (worldPos.Y < SeaLevel) blockType = (byte)VoxelEngineEnums.BlockType.Dirt;

					voxels[x + (y * ChunkSize) + (z * ChunkSize * ChunkSize)] = blockType;
				}
			}
		}
		return voxels;
	}

	public void InitializeChunk(Vector3I coord)
	{
		var data = new ChunkData(RenderingServer.MeshCreate(), RenderingServer.InstanceCreate());
		_activeChunks[coord] = data;
	}

	// Unified logic to apply geometry to a mesh RID
	private void ApplyGeometryToMesh(Rid meshRid, Godot.Collections.Array vertices, Godot.Collections.Array normals, Godot.Collections.Array tangents, Godot.Collections.Array uvs)
	{
		RenderingServer.MeshClear(meshRid);
		
		var surfaceArray = new Godot.Collections.Array();
		surfaceArray.Resize((int)Mesh.ArrayType.Max);
		
		surfaceArray[(int)Mesh.ArrayType.Vertex]  = vertices;
		surfaceArray[(int)Mesh.ArrayType.Normal]  = normals;
		surfaceArray[(int)Mesh.ArrayType.Tangent] = tangents;
		surfaceArray[4] = uvs;

		RenderingServer.MeshAddSurfaceFromArrays(
			meshRid, 
			RenderingServer.PrimitiveType.Triangles, 
			surfaceArray
		);
	}

	public void BakeMeshToRid(Vector3I coord, byte[] data, Rid meshRid)
	{
		byte[] dataCopy = (byte[])data.Clone();
		
		// Create a local snapshot of the dictionary to avoid thread contention
		var dictSnapshot = new System.Collections.Generic.Dictionary<Vector3I, byte[]>(_chunksData);
		
		Task.Run(() =>
		{
			var geometry = VoxelEngineHexagon.CalculateTexturedChunkGeometry(
				dataCopy, coord, dictSnapshot, ChunkSize
			);
			
			// Unpack here to satisfy Variant requirements
			CallDeferred(nameof(ApplyGeometryToMesh), 
				meshRid, 
				ToGodotArray(geometry.Vertices), 
				ToGodotArray(geometry.Normals), 
				ToGodotArray(geometry.Tangents), 
				ToGodotArray(geometry.Uvs)
			);
		});
	}
	
	private Godot.Collections.Array ToGodotArray<T>(System.Collections.Generic.IEnumerable<T> collection)
	{
		var arr = new Godot.Collections.Array();
		foreach (var item in collection) arr.Add(Variant.From(item));
		return arr;
	}
}
