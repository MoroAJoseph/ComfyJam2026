using Godot;

public interface IVoxelGeometry
{
	int FaceCount { get; }
	Vector3[] Vertices { get; }
	
	Vector3 GetNormal(int face);
	int[][] GetTriangles(int face);
	Vector3I GetNeighborOffset(int face, Vector3I currentPos);
	Vector3 GetWorldPosition(Vector3I gridPos);
	Vector3I WorldToGridPosition(Vector3 worldPos);
	Vector2 GetUV(int face, int vertexIndex, int sideIndex = 0);
	Vector3I GetChunkIndex(Vector3 worldPos, int chunkSize);
	Vector3 GetChunkWorldOrigin(Vector3I chunkIndex, int chunkSize);
}
