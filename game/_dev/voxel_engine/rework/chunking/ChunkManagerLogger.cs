using Godot;
using System;

public partial class ChunkManagerLogger : Resource
{
	public enum LogState 
	{ 
		Fps, 
		Mesh, 
		Both, 
		None 
	}

	[Export] public LogState CurrentLogState = LogState.None;

	public ChunkManager ChunkManager;
	public bool IsLogging = false;
	private ulong _startTime;
	private int _frameLogs = 0;

	public void EnableLogging(Node from)
	{
		if (CurrentLogState == LogState.None) return;

		IsLogging = true;

		GD.Print(Time.GetDatetimeDictFromSystem());
		GD.Print($"meshing_algo_name {ChunkManager.MeshingAlgorithm.Name}");
		GD.Print($"terrain_algo_name {ChunkManager.TerrainAlgorithm.CreateName()}");
		GD.Print($"dimensions {ChunkManager.ChunkSize} {ChunkManager.TerrainAlgorithm.MaxHeight} {ChunkManager.ChunkSize}");

		if (CurrentLogState != LogState.Mesh)
		{
			var timer = new Timer();
			from.AddChild(timer);
			timer.OneShot = false;
			timer.Timeout += LogFrameInfo;
			timer.Start();
		}
	}

	public void StartTimeLog()
	{
		if (!IsLogging || CurrentLogState == LogState.Fps) return;

		_startTime = Time.GetTicksUsec();
	}

	public void EndTimeLog(Chunk chunk, Vector3 chunkPosition)
	{
		if (!IsLogging || CurrentLogState == LogState.Fps) return;

		string posString = $"{chunkPosition.X}-{chunkPosition.Y}-{chunkPosition.Z}";
		ulong endTime = Time.GetTicksUsec();
		ulong elapsedTime = endTime - _startTime;
		
		// Ensure you call the method with ()
		int voxelCount = chunk.ChunkData.NumberOfVoxels();
		int vertCount = chunk.MeshData.NumberOfVertices;
		
		GD.Print($"{posString} {voxelCount} {vertCount} {elapsedTime}");
	}

	private void LogFrameInfo()
	{
		var fps = Performance.GetMonitor(Performance.Monitor.TimeFps);
		var mem = Performance.GetMonitor(Performance.Monitor.MemoryStatic);
		var primitives = Performance.GetMonitor(Performance.Monitor.RenderTotalPrimitivesInFrame);
		
		GD.Print($"{_frameLogs} {fps} {mem} {primitives}");
		_frameLogs++;
	}
}
