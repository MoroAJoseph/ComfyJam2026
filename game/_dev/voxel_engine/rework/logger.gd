class_name ChunkManagerLogger extends Resource

enum LogState { 
	FPS, 
	MESH, 
	BOTH, 
	NONE
}
@export var log_state: LogState = LogState.NONE

var chunk_manager: ChunkManager
var is_logging: bool = false
var start_time
var frame_logs: int = 0

func enable_logging(from: Node) -> void:
	if log_state == LogState.NONE: return
	
	is_logging = true
	
	print(Time.get_datetime_dict_from_system())
	print("meshing_algo_name " + chunk_manager.meshing_algorithm.Name)
	print("terrain_algo_name " + chunk_manager.terrain_algorithm.create_name())
	print("dimensions " + str(chunk_manager.chunk_size) + " " + str(chunk_manager.terrain_algorithm.max_height) + " " + str(chunk_manager.chunk_size))
	
	if log_state != LogState.MESH:
		var timer = Timer.new()
		from.add_child(timer)
		timer.one_shot = false
		timer.timeout.connect(log_frame_info)
		timer.start()
		

func start_time_log() -> void:
	if !is_logging || log_state == LogState.FPS: return
	
	start_time = Time.get_ticks_usec()


func end_time_log(chunk: Chunk, chunk_position: Vector3) -> void:
	if !is_logging || log_state == LogState.FPS: return
	
	var pos_string = str(chunk_position.x) + "-" + str(chunk_position.y) + "-" +str(chunk_position.z)
	
	var end_time = Time.get_ticks_usec()
	var elapsed_time = end_time - start_time
	print(pos_string + " " + str(chunk.chunk_data.NumberOfVoxels()) + " " + str(chunk.mesh_data.NumberOfVertices()) + " " + str(elapsed_time))


func log_frame_info() -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var mem = Performance.get_monitor(Performance.MEMORY_STATIC)
	var primitives = Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	print(str(frame_logs) + " " + str(fps) + " " + str(mem) + " " + str(primitives))
	frame_logs += 1
