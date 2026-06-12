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
}
