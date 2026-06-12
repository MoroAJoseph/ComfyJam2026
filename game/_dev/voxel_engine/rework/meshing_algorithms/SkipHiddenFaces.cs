using Godot;
using System;

[GlobalClass]
public partial class SkipHiddenFaces : MeshingAlgorithm
{
	public SkipHiddenFaces()
	{
		Name = "SkipHiddenFaces";
	}

	public override void GenerateMesh(ChunkData chunkData, MeshData meshData)
	{
		if (Geometry == null || chunkData.IsEmpty()) return;

		int size = chunkData.GetSize();

		for (int x = 0; x < size; ++x) {
			for (int y = 0; y < size; ++y) {
				for (int z = 0; z < size; ++z) {
					ChunkData.Voxel voxel = chunkData.GetVoxel(x, y, z);
					if (voxel == ChunkData.Voxel.AIR) continue;

					Vector3I position = new Vector3I(x, y, z);

					// Loop dynamically through whatever number of faces the geometry has (6 for cube, 8 for hex)
					for (int face = 0; face < Geometry.FaceCount; face++) {
						if (!HasNeighbour(chunkData, position, face, size)) {
							AddFace(position, face, voxel, meshData);
						}
					}
				}
			}
		}
	}

	private bool HasNeighbour(ChunkData chunkData, Vector3I position, int face, int chunkSize)
	{
		Vector3I neighbor = position + Geometry.GetNeighborOffset(face, position);
		
		// BOUNDARY GUARD: If neighbor falls outside this local chunk's bounds, 
		// treat it as open air (false) so the outer face is rendered.
		if (neighbor.X < 0 || neighbor.X >= chunkSize ||
			neighbor.Y < 0 || neighbor.Y >= chunkSize ||
			neighbor.Z < 0 || neighbor.Z >= chunkSize)
		{
			return false; 
		}

		return chunkData.GetVoxel(neighbor.X, neighbor.Y, neighbor.Z) != ChunkData.Voxel.AIR;
	}

	private void AddFace(Vector3I position, int face, ChunkData.Voxel voxel, MeshData meshData)
	{
		Color color = Colors[voxel];
		int[][] triangles = Geometry.GetTriangles(face);

		// FIX: Use the active Geometry resource to turn our grid coordinate into the right shape layout location!
		Vector3 worldPosOffset = Geometry.GetWorldPosition(position);

		foreach (int[] triangle in triangles) {
			foreach (int vertexIndex in triangle) {
				// Combine the shape-calculated position with the individual vertex model layout points
				Vector3 worldVertex = worldPosOffset + Geometry.Vertices[vertexIndex];
				meshData.AddData(worldVertex, Geometry.GetNormal(face), color);
			}
		}
	}
}
