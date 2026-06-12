using Godot;
using System;

[GlobalClass]
public partial class SkipHiddenFaces : MeshingAlgorithm
{
	public SkipHiddenFaces() => Name = "SkipHiddenFaces";

	public override void GenerateMesh(
		ChunkData chunkData,
		MeshData meshData,
		Vector3 chunkOrigin,
		IVoxelDataProvider provider
	)
	{
		if (Geometry == null || chunkData.IsEmpty())
			return;

		int size = chunkData.GetSize();

		for (int x = 0; x < size; ++x)
		{
			for (int y = 0; y < size; ++y)
			{
				for (int z = 0; z < size; ++z)
				{
					Voxel voxel = chunkData.GetVoxel(x, y, z);

					if (voxel == Voxel.AIR)
						continue;

					Vector3I position = new Vector3I(x, y, z);

					for (int face = 0; face < Geometry.FaceCount; face++)
					{
						if (!HasNeighbour(
								chunkData,
								position,
								face,
								size,
								chunkOrigin,
								provider))
						{
							AddFace(position, face, voxel, meshData);
						}
					}
				}
			}
		}
	}

	private void AddFace(
		Vector3I position,
		int face,
		Voxel voxel,
		MeshData meshData)
	{
		Color color =
			(Colors != null && Colors.ContainsKey(voxel))
				? Colors[voxel]
				: Godot.Colors.White;

		int[][] triangles = Geometry.GetTriangles(face);

		// LOCAL chunk-space position
		Vector3 localPosOffset = Geometry.GetWorldPosition(position);

		Vector3 tangentEncoder = new Vector3((int)voxel, 0f, 0f);

		foreach (int[] triangle in triangles)
		{
			int[] faceIndices = new int[3];

			for (int i = 0; i < 3; i++)
			{
				int vertexIndex = triangle[i];

				Vector3 vertex =
					localPosOffset +
					Geometry.Vertices[vertexIndex];

				Vector2 uv = Geometry.GetUV(face, vertexIndex);

				faceIndices[i] = meshData.AddVertex(
					vertex,
					Geometry.GetNormal(face),
					color,
					uv,
					tangentEncoder);
			}

			meshData.AddTriangle(
				faceIndices[0],
				faceIndices[1],
				faceIndices[2]);
		}
	}

	private bool HasNeighbour(
		ChunkData chunkData,
		Vector3I localPos,
		int face,
		int size,
		Vector3 chunkOrigin,
		IVoxelDataProvider provider
	)
	{
		Vector3I neighborLocal =
			localPos + Geometry.GetNeighborOffset(face, localPos);

		if (neighborLocal.X >= 0 &&
			neighborLocal.X < size &&
			neighborLocal.Y >= 0 &&
			neighborLocal.Y < size &&
			neighborLocal.Z >= 0 &&
			neighborLocal.Z < size)
		{
			return chunkData.GetVoxel(
				neighborLocal.X,
				neighborLocal.Y,
				neighborLocal.Z) != Voxel.AIR;
		}

		Vector3I chunkBase = new Vector3I(
			Mathf.FloorToInt(chunkOrigin.X / 1.0f),
			Mathf.FloorToInt(chunkOrigin.Y / 1.0f),
			Mathf.FloorToInt(chunkOrigin.Z / 1.0f)
		);

		Vector3I globalPos = chunkBase + neighborLocal;

		return provider.GetVoxelAt(globalPos) != Voxel.AIR;
	}
}
