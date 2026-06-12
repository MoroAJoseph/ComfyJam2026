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

					for (int face = 0; face < Geometry.FaceCount; face++) {
						if (!HasNeighbour(chunkData, position, face, size)) {
							AddFace(position, face, voxel, meshData);
						}
					}
				}
			}
		}
	}
	
	private void AddFace(Vector3I position, int face, ChunkData.Voxel voxel, MeshData meshData)
	{
		Color color = Colors[voxel];
		int[][] triangles = Geometry.GetTriangles(face);
		Vector3 worldPosOffset = Geometry.GetWorldPosition(position);

		// COMPROMISE FIX: Direct 1-to-1 enum cast to find the texture index card
		int textureLayerIndex = (int)voxel;

		// Pack the layer slice index into the vertex tangent vector
		Vector3 tangentEncoder = new Vector3(textureLayerIndex, 0f, 0f);

		foreach (int[] triangle in triangles) {
			foreach (int vertexIndex in triangle) {
				Vector3 worldVertex = worldPosOffset + Geometry.Vertices[vertexIndex];
				Vector2 uv = Geometry.GetUV(face, vertexIndex);

				meshData.AddData(worldVertex, Geometry.GetNormal(face), color, uv, tangentEncoder);
			}
		}
	}
	
	private bool HasNeighbour(ChunkData chunkData, Vector3I position, int face, int chunkSize)
	{
		Vector3I neighbor = position + Geometry.GetNeighborOffset(face, position);
		if (neighbor.X < 0 || neighbor.X >= chunkSize ||
			neighbor.Y < 0 || neighbor.Y >= chunkSize ||
			neighbor.Z < 0 || neighbor.Z >= chunkSize)
		{
			return false; 
		}
		return chunkData.GetVoxel(neighbor.X, neighbor.Y, neighbor.Z) != ChunkData.Voxel.AIR;
	}
}
