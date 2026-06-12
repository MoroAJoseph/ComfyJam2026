using Godot;
using System.Collections.Generic;

[GlobalClass]
public partial class MeshData : Resource
{
	private Godot.Collections.Array surfaceArray = new Godot.Collections.Array();
	private List<Vector3> vertices = new List<Vector3>();
	private List<int> indices = new List<int>();
	private List<Vector3> normals = new List<Vector3>();
	private List<Color> colors = new List<Color>();
	private List<Vector2> uvs = new List<Vector2>();
	private List<float> tangents = new List<float>();

	private int numberOfVertices = 0;
	public int NumberOfVertices => numberOfVertices;
	public int IndicesCount => indices.Count;

	public MeshData()
	{
		surfaceArray.Resize((int)Mesh.ArrayType.Max);
	}

	public void Commit()
	{
		// Must clear before re-populating to avoid residual data issues
		surfaceArray.Clear();
		surfaceArray.Resize((int)Mesh.ArrayType.Max);

		surfaceArray[(int)Mesh.ArrayType.Vertex] = vertices.ToArray();
		surfaceArray[(int)Mesh.ArrayType.Index] = indices.ToArray();
		surfaceArray[(int)Mesh.ArrayType.Normal] = normals.ToArray();
		surfaceArray[(int)Mesh.ArrayType.Color] = colors.ToArray();
		surfaceArray[(int)Mesh.ArrayType.TexUV] = uvs.ToArray();
		surfaceArray[(int)Mesh.ArrayType.Tangent] = tangents.ToArray();
	}

	public void AddData(Vector3 vertex, Vector3 normal, Color color, Vector2 uv, Vector3 tangent)
	{
		AddVertex(vertex, normal, color, uv, tangent);
	}

	public int AddVertex(Vector3 vertex, Vector3 normal, Color color, Vector2 uv, Vector3 tangent)
	{
		vertices.Add(vertex);
		normals.Add(normal);
		colors.Add(color);
		uvs.Add(uv);
		// Tangents are 4-float arrays in Godot (X, Y, Z, W)
		tangents.Add(tangent.X);
		tangents.Add(tangent.Y);
		tangents.Add(tangent.Z);
		tangents.Add(1.0f);
		numberOfVertices++;
		return vertices.Count - 1;
	}

	public void AddTriangle(int a, int b, int c)
	{
		indices.Add(a);
		indices.Add(b);
		indices.Add(c);
	}

	public bool IsEmpty() => numberOfVertices <= 0 || indices.Count <= 0;

	public Godot.Collections.Array GetSurfaceArray() => surfaceArray;

	public void Reset()
	{
		vertices.Clear();
		indices.Clear();
		normals.Clear();
		colors.Clear();
		uvs.Clear();
		tangents.Clear();
		numberOfVertices = 0;
	}
}
