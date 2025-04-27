class_name GhostData

var time : float = 0.0
var global_position : Vector2

func to_line():
	return "%s / %s " % [var_to_str(time), var_to_str(global_position)]

static func from_line(line : String):
	var g : GhostData = GhostData.new()
	var data : PackedStringArray = line.split(" / ")
	if data.size() == 2:
		g.time = str_to_var(data[0])
		g.global_position = str_to_var(data[1])
	else:
		push_error("Incorrect ghost_data line format. Data size was %d" %data.size())
		
	return g
