extends Node

var _ghost_data = []
var _running_time = 0

var player_first_move = false
@export var player : CharacterBody2D

func _ready() -> void:
	Events.connect("player_first_move", start_recording)

func _physics_process(delta: float) -> void:
	if player_first_move:
		var data : GhostData = GhostData.new()
		data.global_transform = player.ghost_marker.global_transform
		data.animation = player.animated_sprite.animation
		data.frame = player.animated_sprite.frame
		data.flip_h = player.animated_sprite.flip_h
		add_ghost_data(data, delta)

func start_recording():
	player_first_move = true

func add_ghost_data(data : GhostData, delta : float):
	if _ghost_data.size() == 0:
		_running_time = 0
		data.time = 0
	else:
		_running_time += delta
		data.time = _running_time
	
	_ghost_data.append(data)

func save_data_to_file(levelName : String):
	if !DirAccess.dir_exists_absolute("user://GhostData/"+levelName):
		DirAccess.make_dir_recursive_absolute("user://GhostData/"+levelName)
	var file = FileAccess.open("user://GhostData/"+ levelName + "/ghost_data_" + levelName + "_" + Save.player_UID + ".dat", FileAccess.WRITE)
	for g in _ghost_data:
		file.store_string(g.to_line())
	file.close()
