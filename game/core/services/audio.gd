class_name AudioService
extends RefCounted

func sync_bus(bus: Enums.AudioBus) -> void:
	var bus_index: int
	var volume: float
	
	match bus:
		Enums.AudioBus.MASTER:
			bus_index = AudioServer.get_bus_index("Master")
			volume = Session.settings_context.master_volume
		Enums.AudioBus.MUSIC:
			bus_index = AudioServer.get_bus_index("Music")
			volume = Session.settings_context.music_volume
		Enums.AudioBus.SFX:
			bus_index = AudioServer.get_bus_index("SFX")
			volume = Session.settings_context.sfx_volume
	
	AudioServer.set_bus_volume_db(bus_index, volume)

func get_bus_index(bus: Enums.AudioBus) -> int:
	match bus:
		Enums.AudioBus.MASTER: return AudioServer.get_bus_index("Master")
		Enums.AudioBus.MUSIC: return AudioServer.get_bus_index("Music")
		Enums.AudioBus.SFX: return AudioServer.get_bus_index("SFX")
		_: return -1

func get_bus_volume(bus: Enums.AudioBus) -> float:
	
	match bus:
		Enums.AudioBus.MASTER: return AudioServer.get_bus_volume_linear()
		Enums.AudioBus.MUSIC: return AudioServer.get_bus_index("Music")
		Enums.AudioBus.SFX: return AudioServer.get_bus_index("SFX")
		_: return -1
