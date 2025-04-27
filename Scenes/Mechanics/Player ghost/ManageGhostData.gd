extends Node

var _ghost_data = []
var _running_time = 0



func add_ghost_data(data : GhostData, delta : float):
	if _ghost_data.size() == 0:
		_running_time = 0
		data.time
	else:
		_running_time += delta
		data.time = _running_time
	
	_ghost_data.append(data)

func save_data_to_file():
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	for g in _ghost_data:
		file.store_string(g.to_line())
