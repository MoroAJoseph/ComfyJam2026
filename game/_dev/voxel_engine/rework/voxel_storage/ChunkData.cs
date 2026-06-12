using Godot;
using System;

[GlobalClass]
public partial class ChunkData : Resource
{
	private Voxel[] voxels;
	private int size = 16; // Default changed to 16 to match your Manager
	private int numberOfVoxels = 0;

	public int GetSize() => size;

	public void SetSize(int newSize)
	{
		size = newSize;
		voxels = new Voxel[size * size * size];
		// Array is initialized to default Voxel (AIR) automatically in C#
		numberOfVoxels = 0;
	}
	
	public int NumberOfVoxels()
	{
		return numberOfVoxels;
	}
	
	public void AddVoxel(int x, int y, int z, Voxel voxel)
	{
		if (x < 0 || y < 0 || z < 0 || x >= size || y >= size || z >= size) return;

		int index = positionToIndex(x, y, z);
		Voxel oldVoxel = voxels[index];

		// Only update counter if the state actually changes
		if (oldVoxel == Voxel.AIR && voxel != Voxel.AIR)
			numberOfVoxels++;
		else if (oldVoxel != Voxel.AIR && voxel == Voxel.AIR)
			numberOfVoxels--;

		voxels[index] = voxel;
	}

	public void RemoveVoxel(int x, int y, int z)
	{
		// Use AddVoxel logic to ensure counter stays synchronized
		AddVoxel(x, y, z, Voxel.AIR);
	}

	public Voxel GetVoxel(int x, int y, int z)
	{
		if (x < 0 || y < 0 || z < 0 || x >= size || y >= size || z >= size) return Voxel.AIR;
		return voxels[positionToIndex(x, y, z)];
	}

	public bool IsEmpty() => numberOfVoxels <= 0;

	private int positionToIndex(int x, int y, int z)
	{
		return x + (y * size) + (z * size * size);
	}
}
