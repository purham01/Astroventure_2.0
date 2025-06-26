extends Node2D

@onready var visual: AnimatedSprite2D = $Visual
@onready var fuel_tank: AnimatedSprite2D = $Visual/FuelTank
@onready var player_name_label: Label = $PlayerNameLabel

@onready var particle_manager: Node = $ParticleManager

@export var disable = false


const _JITTER_LERP_SPEED = 0.2

var player_first_move = false

var _ghost_data = []
var i = 0
var _running_time = 0
@export var dont_run = false

var fuel_tank_offset = {
	"idle,0" : Vector2(0,0),
	"run,0" : Vector2(0,0),
	"run,1" : Vector2(0,1),
	"run,2" : Vector2(0,1),
	"run,3" : Vector2(0,1),
	"run,4" : Vector2(0,0),
	"run,5" : Vector2(0,0),
	"run,6" : Vector2(0, 1),
	"run,7" : Vector2(0,1),
	"run,8" : Vector2(0,1),
	"run,9" : Vector2(0,1),
	"run,10" : Vector2(0,0),
	"run,11" : Vector2(0,0),
	"jump,0" : Vector2(0,0),
	"jump,1" : Vector2(0,0),
	"fall,0" : Vector2(1,0),
	"fall,1" : Vector2(1,0),
	"dash,0" : Vector2(1,1),
	"dash,1" : Vector2(1,1),
	"dash,2" : Vector2(1,1),
	"dash,3" : Vector2(1, 1),
	"wallslide,0" : Vector2(2,0),
	"climb,0" : Vector2(2, 0),
	"climb,1" : Vector2(2,0),
	"climb,2" : Vector2(2,0),
	"climb,3" : Vector2(2,0),
	"climb,4" : Vector2(2,0),
	"climb,5" : Vector2(2,0),
	"climb_look_back,0" : Vector2(2,0),
	"climb_look_back,1" : Vector2(2,0),
	"climb_look_back,2" : Vector2(2,0),
	"climb_look_back,3" : Vector2(2,0)
	
}

var ready_to_run = true

func _ready() -> void:
	ready_to_run = false
	Events.connect("player_first_move", start_moving)
	
	if Save.player_UID == "":
		await Events.player_logged_in
	
	if LeaderboardManager.player_ghost_name != "":
		player_name_label.text = LeaderboardManager.player_ghost_name
	else:
		player_name_label.text = Save.save_data.get("PlayerName")
	
	
	if LeaderboardManager.ghost_data_id_to_load != "":
		print("Ghost data to load: ", LeaderboardManager.ghost_data_id_to_load)
		load_data_from_file(get_parent().name, LeaderboardManager.ghost_data_id_to_load)
	else:
		print("Ghost data to load: ", Save.player_UID)
		load_data_from_file(get_parent().name, Save.player_UID)
	#print(_ghost_data)
	if !disable:
		global_transform = _ghost_data[0].global_transform
		visual.global_transform = _ghost_data[0].global_transform
		#visible = true
		ready_to_run = true

func _process(delta: float) -> void:
	visual.global_position = visual.global_position.lerp(global_position, pow(0.5, delta * _JITTER_LERP_SPEED))
	visual.rotation = rotation
	#visual.global_transform.interpolate_with(global_transform,pow(0.5, delta * _JITTER_LERP_SPEED))
	manage_fuel_tank_anim()

func _physics_process(delta: float) -> void:
	if player_first_move and !dont_run:
		if i < _ghost_data.size() and _running_time >= _ghost_data[i].time:
			global_transform = _ghost_data[i].global_transform
			visual.animation = _ghost_data[i].animation
			if visual.animation == "dash" and particle_manager.dash_ghost_timer.is_stopped():
				particle_manager.dash_ghost_timer.start()
			elif visual.animation != "dash" and !particle_manager.dash_ghost_timer.is_stopped():
				particle_manager.dash_ghost_timer.stop()
			if visual.animation == "poof" and fuel_tank.visible:
				fuel_tank.hide()
			elif visual.animation != "poof" and !fuel_tank.visible:
				fuel_tank.show()
			visual.frame = _ghost_data[i].frame
			visual.flip_h = _ghost_data[i].flip_h
			i+=1
		_running_time += delta
		#print("Player ghost global transform: ", global_transform)
		#print("Player ghost sprite gt: ", visual.global_transform)
		#print("")

func start_moving():
	player_first_move = true

func manage_fuel_tank_anim():
	fuel_tank.flip_h = visual.flip_h
	var fetch = visual.animation + "," + str(visual.frame)
	#print(fetch)
	if fuel_tank_offset.get(fetch) != null:
		var value = fuel_tank_offset.get(fetch)
		if fuel_tank.flip_h:
			value.x *= -1
		fuel_tank.offset = value

func load_data_from_file(levelName : String, player_id = Save.player_UID):
	print("Data path: ", "user://GhostData/" + levelName +"/ghost_data_" + levelName + "_" + player_id + ".dat")
	var file = FileAccess.open("user://GhostData/" + levelName +"/ghost_data_" + levelName + "_" + player_id + ".dat", FileAccess.READ)
	if file != null:
		var content = file.get_as_text()
		for line in content.split("\n"):
			if line != "":
				_ghost_data.append(GhostData.from_line(line))
	else:
		disable = true
