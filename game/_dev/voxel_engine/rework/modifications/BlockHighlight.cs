using Godot;
using System;

public partial class BlockHighlight : Node3D
{
	[Export] public RayCast3D Ray;
	private MeshInstance3D _meshInstance;
	private string _currentGeometryType = "";

	public override void _Ready() => _meshInstance = GetNode<MeshInstance3D>("MeshInstance3D");

	public override void _PhysicsProcess(double delta)
	{
		// Access ChunkManager via our new Terrain Singleton
		var manager = Terrain.Instance?.Manager;
		var geom = manager?.MeshingAlgorithm?.ScriptGeometry as IVoxelGeometry;

		if (!Ray.IsColliding() || geom == null)
		{
			Visible = false;
			return;
		}

		Visible = true;
		bool isHex = geom.GetType().Name.Contains("Hex");
		string targetType = isHex ? "HEX" : "CUBE";

		if (targetType != _currentGeometryType) UpdateHighlightMesh(isHex);

		Vector3 hitPoint = Ray.GetCollisionPoint();
		Vector3 hitNormal = Ray.GetCollisionNormal();

		// Edge Slip Fix: Force cardinal direction
		Vector3 cleanNudge = Vector3.Zero;
		if (Math.Abs(hitNormal.X) > Math.Abs(hitNormal.Y) && Math.Abs(hitNormal.X) > Math.Abs(hitNormal.Z))
			cleanNudge.X = Math.Sign(hitNormal.X) * 0.02f;
		else if (Math.Abs(hitNormal.Y) > Math.Abs(hitNormal.Z))
			cleanNudge.Y = Math.Sign(hitNormal.Y) * 0.02f;
		else
			cleanNudge.Z = Math.Sign(hitNormal.Z) * 0.02f;

		Vector3I gridPos = geom.WorldToGridPosition(hitPoint - cleanNudge);
		Vector3 blockCenter = geom.GetWorldPosition(gridPos);

		GlobalPosition = isHex ? blockCenter + new Vector3(0, 0.5f, 0) : blockCenter + new Vector3(0.5f, 0.5f, 0.5f);
	}

	private void UpdateHighlightMesh(bool isHex)
	{
		_currentGeometryType = isHex ? "HEX" : "CUBE";
		var mat = new StandardMaterial3D { 
			Transparency = BaseMaterial3D.TransparencyEnum.Alpha, 
			AlbedoColor = new Color(1, 1, 1, 0.25f), 
			EmissionEnabled = true, 
			Emission = Colors.White, 
			EmissionEnergyMultiplier = 0.15f 
		};
		
		_meshInstance.Mesh = isHex ? 
			(Mesh)new CylinderMesh { RadialSegments = 6, TopRadius = 1.02f, BottomRadius = 1.02f, Height = 1.02f } : 
			(Mesh)new BoxMesh { Size = new Vector3(1.02f, 1.02f, 1.02f) };
		_meshInstance.MaterialOverride = mat;
	}
}
