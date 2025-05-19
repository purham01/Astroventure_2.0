class_name GhostData

var time : float = 0.0
var global_transform : Transform2D
var animation : StringName = ""
var frame : int = 0
var flip_h : bool = false

func to_line():
	return "%s / %s / %s / %s / %s\n" % [var_to_str(time), var_to_str(global_transform), var_to_str(animation), var_to_str(frame), var_to_str(flip_h) ]

static func from_line(line : String):
	var g : GhostData = GhostData.new()
	var data : PackedStringArray = line.split(" / ")
	if data.size() == 5:
		g.time = str_to_var(data[0])
		g.global_transform = str_to_var(data[1])
		g.animation = str_to_var(data[2])
		g.frame = str_to_var(data[3])
		g.flip_h = str_to_var(data[4])
	else:
		push_error("Incorrect ghost_data line format. Data size was %d" %data.size())
		
	return g

func _to_string() -> String:
	return "%s / %s / %s / %s / %s\n" % [var_to_str(time), var_to_str(global_transform), var_to_str(animation), var_to_str(frame), var_to_str(flip_h) ]
