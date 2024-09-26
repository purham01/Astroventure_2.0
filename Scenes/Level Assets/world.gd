extends Node2D

@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var start_in = %StartIn
@onready var start_in_label = %StartInLabel
@onready var animation_player = $AnimationPlayer
@onready var level_time_label = %LevelTimeLabel
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var player = $Player
@onready var music_player = $MusicPlayer



@export var next_level: PackedScene
@export var countdown = false
@export var timer = false
@export var scene_tile_name : PackedScene
@export var level_best_time : float
@export var music : AudioStreamOggVorbis

var level_time = 0.0
var start_level_msec = 0.0
var heartsMax = 0
var heartsCollected = 0


func _ready():
	heartsMax = get_tree().get_nodes_in_group("Hearts").size()
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.level_completed.connect(show_level_completed)
	Events.update_score.connect(update_score)
	get_tree().paused = true
	LevelTransition.fade_from_black()
	if countdown:
		animation_player.play("countdown")
		await animation_player.animation_finished
	get_tree().paused = false
	start_level_msec = Time.get_ticks_msec() #vrijeme od pocetka u ms
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "Map screen"
	addObjects()

func addObjects():
	var usedCells = $LevelTileMap.get_used_cells(2)
	for cell in usedCells:
		var cellSrcId = $LevelTileMap.get_cell_source_id(2, cell)
		var cellAlt = $LevelTileMap.get_cell_alternative_tile(2, cell)
		var place_at = to_global($LevelTileMap.map_to_local(cell))
		if cellSrcId == 3:
			place_scene_tile(place_at, 2, cellAlt)
	$LevelTileMap.clear_layer(2)

func place_scene_tile(place_at, cellLayer, cellAlt):
	if scene_tile_name:
		var scene_tile_instance = scene_tile_name.instantiate()
		add_child(scene_tile_instance)
		if cellAlt == 0:
			pass	# zbog offseta i toga kako se rotira morate ih namistit malo,
					# a brojevi ovise o vasem centru i tilemapu
			#place_at.x -= 8
			#place_at.y += 8
		elif cellAlt == 2:
			scene_tile_instance.rotation = PI
			#place_at.x += 8
			#place_at.y -= 8
		elif cellAlt == 3:
			scene_tile_instance.rotation = 1.5 * PI
			#place_at.x += 8
			#place_at.y += 8
		elif cellAlt == 4:
			scene_tile_instance.rotation = 0.5 * PI
			#place_at.x -= 8
			#place_at.y -= 8
		scene_tile_instance.position = place_at

func _process(delta):
	level_time = Time.get_ticks_msec() - start_level_msec
	if timer:
		level_time_label.text = str(level_time / 1000.0)

func show_level_completed():
	player._end_level_anim()
	await(player.animation_player.animation_finished)
	await(player.animated_sprite.animation_finished)
	$DelayEndLevel.start()
	await($DelayEndLevel.timeout)
	level_time_label.hide()
	level_completed.show_data(heartsCollected, heartsMax, float(level_time_label.text), level_best_time)
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
	heartsCollected+=1
	print(heartsCollected)
