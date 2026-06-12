using Godot;


public partial class BlockModification : RayCast3D
{
	public struct RayHit { public Vector3 Remove; public Vector3 Add; }

	public RayHit? GetRayHit()
	{
		if (GetCollider() is not Chunk) return null;
		
		Vector3 normal = GetCollisionNormal();
		Vector3 point = GetCollisionPoint();
		
		return new RayHit { 
			Remove = point - (normal * 0.01f), 
			Add = point + (normal * 0.01f) 
		};
	}
}
