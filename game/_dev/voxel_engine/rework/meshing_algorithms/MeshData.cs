using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class MeshData: Resource
{
	private Godot.Collections.Array surfaceArray = [];
	private List<Vector3> vertices = new List<Vector3>();
	private List<Vector3> normals = new List<Vector3>();
	private List<Color> colors = new List<Color>();
	private List<Vector2> uvs = new List<Vector2>();
	private List<float> tangents = new List<float>();
	
	private int numberOfVertices = 0;


	public MeshData(){
		surfaceArray.Resize((int)Mesh.ArrayType.Max);
	}

	public void Commit(){
		surfaceArray[(int)Mesh.ArrayType.Vertex] = vertices.ToArray();
		surfaceArray[(int)Mesh.ArrayType.Normal] = normals.ToArray();
		surfaceArray[(int)Mesh.ArrayType.Color] = colors.ToArray();
		
		if (uvs.Count > 0)
		{
			surfaceArray[(int)Mesh.ArrayType.TexUV] = uvs.ToArray();
		}
		if (tangents.Count > 0)
		{
			surfaceArray[(int)Mesh.ArrayType.Tangent] = tangents.ToArray();
		}
	}

	public void AddData(Vector3 vertex, Vector3 normal, Color color){
		vertices.Add(vertex);
		normals.Add(normal);
		colors.Add(color);
		numberOfVertices++;
	}
	
	public void AddData(Vector3 vertex, Vector3 normal, Color color, Vector2 uv, Vector3 tangent)
	{
		// Fall back to baseline additions
		AddData(vertex, normal, color);
		
		// Map texturing fractions safely
		uvs.Add(uv);
		
		// Pack the 3D encoding tangent space out to flat 4-float vertex properties (X, Y, Z, W)
		tangents.Add(tangent.X);
		tangents.Add(tangent.Y);
		tangents.Add(tangent.Z);
		tangents.Add(1.0f); // Positive orientation sign bit multiplier
	}
	
	public bool IsEmpty(){
		return numberOfVertices <= 0;
	}

	public Godot.Collections.Array GetSurfaceArray(){
		return surfaceArray;
	}

	public int NumberOfVertices(){
		return numberOfVertices;
	}

	public void Reset(){
		surfaceArray.Clear();
		vertices.Clear();
		normals.Clear();
		colors.Clear();
		uvs.Clear();
		tangents.Clear();
		numberOfVertices = 0;
		surfaceArray.Resize((int)Mesh.ArrayType.Max);
	}
}
