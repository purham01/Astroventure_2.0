extends Node2D

@onready var visual: Sprite2D = $Visual
@export var disable = false

const _JITTER_LERP_SPEED = 0.2

var player_first_move = false

var _ghost_data = []
var i = 0
var _running_time = 0
var dont_run = false

func _ready() -> void:
	Events.connect("player_first_move", start_moving)
	load_data_from_file()
	#print(_ghost_data)
	if !dont_run and !disable:
		global_position = _ghost_data[0].global_position
		visual.global_position = _ghost_data[0].global_position
	else:
		visible = false

func _process(delta: float) -> void:
	visual.global_position = visual.global_position.lerp(global_position, pow(0.5, delta * _JITTER_LERP_SPEED))
	
func _physics_process(delta: float) -> void:
	if player_first_move:
		if i < _ghost_data.size() and _running_time >= _ghost_data[i].time:
			global_position = _ghost_data[i].global_position
			i+=1
		_running_time += delta
		#print("Player ghost global transform: ", global_transform)
		#print("Player ghost sprite gt: ", visual.global_transform)
		#print("")

func start_moving():
	player_first_move = true


func load_data_from_file():
	var file = FileAccess.open("user://ghost_data.dat", FileAccess.READ)
	if file != null:
		var content = file.get_as_text()
		for line in content.split("\n"):
			if line != "":
				_ghost_data.append(GhostData.from_line(line))
	else:
		dont_run = true
