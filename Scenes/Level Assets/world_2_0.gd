extends Node2D

@onready var level_completed = $HUD/LevelCompleted
@onready var start_in = %StartIn
@onready var start_in_label = %StartInLabel
@onready var animation_player = $AnimationPlayer
@onready var level_time_label = %LevelTimeLabel
@onready var pause_menu = $HUD/PauseMenu
@onready var player = $Player
@onready var player_camera: Camera2D = $PlayerCamera

@onready var popup_label: Label = %PopupLabel
@onready var popup_timer: Timer = $PopupTimer
@onready var popup_container: MarginContainer = $HUD/PopupContainer

@onready var ghost_recorder: Node2D = $GhostRecorder

@export var next_level: PackedScene
@export var countdown = false
@export var timer = false
@export var scene_tile_name : PackedScene
@export var leaderboard_id : String 
@export var level_codename : String
@export var deity_name : String
@export var always_post_score : bool = false
@export var dont_post_score : bool = false
@export var developing_level = false

@export_category("Medals")
@export var star_destroyer_medal_time = 40.0
@export var galaxy_medal_time = 60.0
@export var nebula_medal_time = 90.0
@export var supernova_medal_time = 120.0
@export var asteroid_medal_time = null

@onready var stars: Node = $Stars
@onready var left_eye: StaticBody2D = %LeftEye
@onready var right_eye: StaticBody2D = %RightEye
@onready var mask: Node2D = $Mask

@onready var player_ghost: Node2D = $PlayerGhost


var level_time = 0.0
var start_level_msec = 0.0
var starsMax = 0
var starsCollected = 0

var player_has_first_moved = false
var level_complete = false

func _ready():
	set_stars()
	set_eyes()
	set_mask()
	setup_player_ghost()
	
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	Events.level_completed.connect(show_level_completed)
	Events.update_score.connect(update_score)
	Events.player_first_move.connect(start_level_timer)
	Events.collected_left_eye.connect(left_eye_collected)
	Events.collected_right_eye.connect(right_eye_collected)
	Events.inserted_left_eye.connect(left_eye_inserted)
	Events.inserted_right_eye.connect(right_eye_inserted)
	
	get_tree().paused = true
	LevelTransition.fade_from_black()
	if countdown:
		animation_player.play("countdown")
		await animation_player.animation_finished
	get_tree().paused = false
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "Map screen"
	pause_menu.leaderboard_id = leaderboard_id
	pause_menu.level_codename = level_codename
	level_completed.leaderboard.leaderboard_id = leaderboard_id
	level_completed.leaderboard.level_codename = level_codename
	#addObjects()
	set_medal_times()
	Events.emit_signal("level_setup_done")

func setup_player_ghost():
	var dict : Dictionary = Save.save_data.get(level_codename)
	
	var left_eye_inserted = dict.get("LeftEyeInserted")
	var right_eye_inserted = dict.get("RightEyeInserted")
	if left_eye_inserted and right_eye_inserted:
		player_ghost.dont_run = false
		player_ghost.visible = true
		Events.emit_signal("enable_leaderboard_ghosts")
	elif left_eye_inserted or right_eye_inserted:
		player_ghost.dont_run = false
		player_ghost.visible = true
	else:
		player_ghost.dont_run = true

func set_mask():
	mask.level_codename = level_codename
	var dict : Dictionary = Save.save_data.get(level_codename)
	
	mask.left_eye_inserted = dict.get("LeftEyeInserted")
	mask.right_eye_inserted = dict.get("RightEyeInserted")
	mask.left_eye_collected = dict.get("LeftEyeCollected")
	mask.right_eye_collected = dict.get("RightEyeCollected")
	
	if dict.get("BestTime") != 0.0 and (dict.get("LeftEyeCollected") or dict.get("RightEyeCollected")):
		mask.set_sprite()
		mask.collision_shape_2d.disabled = false
		mask.show()

func set_eyes():
	left_eye.level_codename = level_codename
	right_eye.level_codename = level_codename
	var dict : Dictionary = Save.save_data.get(level_codename)
	if dict.get("RightEyeCollected"):
		right_eye.queue_free()
	if dict.get("LeftEyeCollected"):
		left_eye.queue_free()

func set_stars():
	var starsNodes = get_tree().get_nodes_in_group("Stars")
	starsMax = starsNodes.size()
	var dict : Dictionary = Save.save_data.get(level_codename)
	var stars_list = dict.get("Stars")
	if stars_list.is_empty() or developing_level:
		stars_list = []
		for i in starsMax:
			stars_list.append(false)
		dict.set("Stars", stars_list)
		Save.save_data.set(level_codename, dict)
		Save.save_game()
	
	var i = 0
	for s in starsNodes:
		s.id = i
		s.level_codename = level_codename
		if stars_list[i]:
			s.set_as_collected()
			update_score()
		i+=1
		

func set_medal_times():
	level_completed.star_destroyer_medal_time = star_destroyer_medal_time
	level_completed.galaxy_medal_time = galaxy_medal_time
	level_completed.nebula_medal_time = nebula_medal_time
	level_completed.supernova_medal_time = supernova_medal_time


#func addObjects():
	#var usedCells = $LevelTileMap.get_used_cells(2)
	#for cell in usedCells:
		#var cellSrcId = $LevelTileMap.get_cell_source_id(2, cell)
		#var cellAlt = $LevelTileMap.get_cell_alternative_tile(2, cell)
		#var place_at = to_global($LevelTileMap.map_to_local(cell))
		#if cellSrcId == 3:
			#place_scene_tile(place_at, 2, cellAlt)
	#$LevelTileMap.clear_layer(2)
#
#func place_scene_tile(place_at, cellLayer, cellAlt):
	#if scene_tile_name:
		#var scene_tile_instance = scene_tile_name.instantiate()
		#add_child(scene_tile_instance)
		#if cellAlt == 0:
			#pass	# zbog offseta i toga kako se rotira morate ih namistit malo,
					## a brojevi ovise o vasem centru i tilemapu
			##place_at.x -= 8
			##place_at.y += 8
		#elif cellAlt == 2:
			#scene_tile_instance.rotation = PI
			##place_at.x += 8
			##place_at.y -= 8
		#elif cellAlt == 3:
			#scene_tile_instance.rotation = 1.5 * PI
			##place_at.x += 8
			##place_at.y += 8
		#elif cellAlt == 4:
			#scene_tile_instance.rotation = 0.5 * PI
			##place_at.x -= 8
			##place_at.y -= 8
		#scene_tile_instance.position = place_at

func _process(delta):
	if player_ghost.dont_run or player_ghost.ready_to_run and player.starting_level:
		player.starting_level = false
	
	if player_has_first_moved and !level_complete:
		level_time = Time.get_ticks_msec() - start_level_msec
		if timer:
			level_time_label.text = str(level_time / 1000.0)

func show_level_completed():
	level_complete = true
	player._end_level_anim()
	
	var level_best_time = Save.save_data.get(level_codename).get("BestTime")
	var new_best = false
	var final_time = level_time/1000.0
	print("Level best time: ", level_best_time)
	print("Level time: ", level_time)
	if always_post_score or level_best_time == 0.0 or final_time < level_best_time:
		var dict : Dictionary = Save.save_data.get(level_codename)
		
		if final_time < star_destroyer_medal_time:
			dict.set("Medal","Star destroyer")
		elif final_time < galaxy_medal_time:
			dict.set("Medal","Galaxy")
		elif final_time < nebula_medal_time:
			dict.set("Medal","Nebula")
		elif final_time < supernova_medal_time:
			dict.set("Medal","Supernova")
		else:
			dict.set("Medal","Asteroid")
		
		dict.set("BestTime", final_time)
		Save.save_data.set(level_codename, dict)
		Save.save_game()
		new_best = true
		if Save.player_UID and !dont_post_score:
			var result = await LeaderboardManager.submit_score(leaderboard_id, level_time)
			level_completed.leaderboard.refresh_scores()
			
			ghost_recorder.save_data_to_file(level_codename)
			Firebase.Storage.ref("GhostData/"+level_codename+ "/"+"ghost_data_" + level_codename + "_" + Save.player_UID + ".dat").put_file("user://GhostData/" + level_codename + "/ghost_data_" + level_codename + "_" + Save.player_UID + ".dat")
		
	
	await(player.animation_player.animation_finished)
	await(player.animated_sprite.animation_finished)
	
	$DelayEndLevel.start()
	await($DelayEndLevel.timeout)
	level_time_label.hide()
	level_completed.show_data(starsCollected, starsMax, float(level_time_label.text), new_best)
	
	
	get_tree().paused = true

func go_to_next_level():
	await LevelTransition.fade_to_black()
	if not next_level is PackedScene: get_tree().change_scene_to_file("res://Scenes/Levels/MapScreen.tscn")
	else: get_tree().change_scene_to_packed(next_level)
	#LevelTransition.fade_from_black()
	#get_tree().paused = false

func _on_level_completed_retry():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().reload_current_scene()


func update_score():
	starsCollected+=1
	print(starsCollected)

func start_level_timer():
	player_has_first_moved = true
	start_level_msec = Time.get_ticks_msec()

func left_eye_collected():
	popup_label.text = "You have collected the Left Eye of %s!" % [deity_name]
	popup_container.show()
	player_camera.apply_shake(1 * ConfigFileHandler.camera_shake, 1.0) 
	popup_timer.start()
	
func right_eye_collected():
	popup_label.text = "You have collected the Right Eye of %s!" % [deity_name]
	popup_container.show()
	player_camera.apply_shake(1 * ConfigFileHandler.camera_shake, 1.0) 
	popup_timer.start()
	
func left_eye_inserted():
	var dict : Dictionary = Save.save_data.get(level_codename)
	var right_eye_inserted = dict.get("RightEyeInserted")
	
	dict.set("LeftEyeInserted", true)
	Save.save_data.set(level_codename, dict)
	Save.save_game()
	
	
	player_camera.apply_shake(2 * ConfigFileHandler.camera_shake) 
	popup_label.text = "You have inserted the Left Eye of %s!" % [deity_name]
	if !right_eye_inserted:
		popup_label.text += "\nYou may now race against your own ghost"
		popup_label.text += "\nRestart the level in order to see it"
	else:
		popup_label.text += "\nYou may now race against the ghosts of other players"
		popup_label.text += "\nGo to the leaderboard in order to select your foe"
	popup_container.show()
	popup_timer.start(10.0)

func right_eye_inserted():
	var dict : Dictionary = Save.save_data.get(level_codename)
	var left_eye_inserted = dict.get("LeftEyeInserted")
	
	dict.set("RightEyeInserted", true)
	Save.save_data.set(level_codename, dict)
	Save.save_game()
	
	player_camera.apply_shake(2 * ConfigFileHandler.camera_shake) 
	popup_label.text = "You have inserted the Right Eye of %s!" % [deity_name]
	if !left_eye_inserted:
		popup_label.text += "\nYou may now race against your own ghost"
		popup_label.text += "\nRestart the level in order to see it"
	else:
		popup_label.text += "\nYou may now race against the ghosts of other players"
		popup_label.text += "\nGo to the leaderboard in order to select your foe"
	popup_container.show()
	popup_timer.start(10.0)

func _on_popup_timer_timeout() -> void:
	animation_player.play("popup_fade")
