extends CanvasLayer

@onready var begin_button = %BeginButton
@onready var abort_button = %AbortButton
@onready var animation_player = $AnimationPlayer
@onready var planet = %Planet
@onready var planet_info = %planet_info
@onready var text_timer = $TextTimer
@onready var disable_input_timer = $DisableInputTimer
@onready var indicator = %Indicator
@onready var planet_name_label = %planet_name
@onready var planet_stats = %planet_stats

@export var next_level: PackedScene

@onready var tab_container: TabContainer = $Control/ColorRect/ColorRect/TabContainer
@onready var communications: MarginContainer = $Control/ColorRect/ColorRect/TabContainer/Communications
@onready var collectibles: MarginContainer = $Control/ColorRect/ColorRect/TabContainer/Collectibles
@onready var leaderboard: MarginContainer = $Control/ColorRect/ColorRect/TabContainer/Leaderboard
@onready var leaderboard_ui: Control = $Control/ColorRect/ColorRect/TabContainer/Leaderboard/LeaderboardUI

@onready var star_grid: GridContainer = %StarGrid
@onready var medal_label: RichTextLabel = %MedalLabel
@onready var medal_sprite: AnimatedSprite2D = %MedalSprite

@onready var star_container = preload("res://Scenes/UI/star_container.tscn")
@onready var eye_container_left: MarginContainer = %EyeContainerLeft
@onready var eye_container_right: MarginContainer = %EyeContainerRight

enum PlanetNames{
	Mercury,
	Venus,
	Earth,
	Mars,
	Jupiter,
	Saturn,
	Uranus,
	Neptune
}

@export var print_speed = 0.001

@onready var uranus_text = load_file("res://Assets/Level dialogues/Uranus.txt")
@onready var mercury_text = load_file("res://Assets/Level dialogues/Mercury.txt")
@onready var neptune_text = load_file("res://Assets/Level dialogues/Neptune.txt")
@onready var venus_text = load_file("res://Assets/Level dialogues/Venus.txt")
@onready var jupiter_text = load_file("res://Assets/Level dialogues/Jupiter.txt")
@onready var earth_text = load_file("res://Assets/Level dialogues/Earth.txt")
@onready var saturn_text = load_file("res://Assets/Level dialogues/Saturn.txt")
@onready var mars_text = load_file("res://Assets/Level dialogues/Mars.txt")

var phraseNum = 0
var finished = false
var no_more_dialogue = false
var dialog 
var disable_dialogue = false

func _ready():
	text_timer.wait_time = print_speed

func load_file(file):
	var file_open = FileAccess.open(file, FileAccess.READ)
	
	#var content = file_open.get_as_text()
	var content : Array 
	while !file_open.eof_reached():
		var line = file_open.get_line()
		content.append(line)
	return content

func nextPhrase() -> void:
	if phraseNum >= len(dialog)-1:
		return
	
	finished = false
	
	planet_info.bbcode_text = dialog[phraseNum]
	
	planet_info.visible_characters = 0
	
	while planet_info.visible_characters < len(planet_info.text):
		planet_info.visible_characters+=1
		
		text_timer.start()
		await(text_timer.timeout)
	
	phraseNum += 1
	finished = true
	if phraseNum >= len(dialog)-1:
		no_more_dialogue = true
	return



func pass_parameters(level : PackedScene, sprite_frames : SpriteFrames, planet_name):
	next_level = level
	planet.sprite_frames = sprite_frames
	planet.play("default")
	tab_container.current_tab = 0
	
	match planet_name:
		PlanetNames.Mercury:
			planet_name_label.text = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 3.70\nTemp: 167°C\nDanger: [color=green]LOW[/color]"
			dialog = mercury_text
			leaderboard_ui.leaderboard_id = ""
			leaderboard_ui.level_codename = "Mercury"
			leaderboard_ui.refresh_scores()
			load_collectibles("Mercury")
		PlanetNames.Venus:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 8.87\nTemp: 464°C\nDanger: [color=orange]MEDIUM[/color]"
			dialog = venus_text
			leaderboard_ui.leaderboard_id = ""
			leaderboard_ui.level_codename = "Venus"
			leaderboard_ui.refresh_scores()
			load_collectibles("Venus")
		PlanetNames.Earth:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 9.80\nTemp: 15°C\nDanger: [color=green]LOW[/color]"
			dialog = earth_text
			leaderboard_ui.leaderboard_id = "30915"
			leaderboard_ui.level_codename = "Earth"
			leaderboard_ui.refresh_scores()
			load_collectibles("Earth")
		PlanetNames.Mars:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 3.71\nTemp: -65°C\nDanger: [color=orange]MEDIUM[/color]"
			dialog = mars_text
			leaderboard_ui.leaderboard_id = ""
			leaderboard_ui.level_codename = "Mars"
			leaderboard_ui.refresh_scores()
			load_collectibles("Mars")
		PlanetNames.Jupiter:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 24.79\nTemp: -110°C\nDanger: [color=red]HIGH[/color]"
			dialog = jupiter_text
			leaderboard_ui.leaderboard_id = "31052"
			leaderboard_ui.level_codename = "Jupiter"
			leaderboard_ui.refresh_scores()
			load_collectibles("Jupiter")
		PlanetNames.Saturn:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 10.44\nTemp: -140°C\nDanger: [color=green]LOW[/color]"
			dialog = saturn_text
			leaderboard_ui.leaderboard_id = ""
			leaderboard_ui.level_codename = "Saturn"
			leaderboard_ui.refresh_scores()
			load_collectibles("Saturn")
		PlanetNames.Uranus:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 8.87\nTemp: -195°C\nDanger: [color=red]HIGH[/color]"
			dialog = uranus_text
			leaderboard_ui.leaderboard_id = ""
			leaderboard_ui.level_codename = "Uranus"
			leaderboard_ui.refresh_scores()
			load_collectibles("Uranus")
		PlanetNames.Neptune:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 11.15\nTemp: -200°C\nDanger: [color=orange]MEDIUM[/color]"
			dialog = neptune_text
			leaderboard_ui.leaderboard_id = "30961"
			leaderboard_ui.level_codename = "Neptune"
			leaderboard_ui.refresh_scores()
			load_collectibles("Neptune")
			

	show()
	phraseNum = 0
	no_more_dialogue = false
	if(dialog):
		nextPhrase()

func load_collectibles(level_codename):
	var dict : Dictionary = Save.save_data.get(level_codename)
	
	if dict.get("BestTime") == 0.0:
		tab_container.set_tab_disabled(1, true)
		tab_container.set_tab_disabled(2, true)
		return
	else:
		tab_container.set_tab_disabled(1, false)
		tab_container.set_tab_disabled(2, false)
		
	
		
	var medal = dict.get("Medal")
	
	if medal == "Star destroyer":
		medal_sprite.scale = Vector2(0.25,0.25)
		medal_sprite.play("black hole")
		medal_label.text = "[color=DARK_ORANGE][shake rate=20.0 level=3 connected=1]Star destroyer medal[/shake][/color]"
	elif medal == "Galaxy":
		medal_sprite.scale = Vector2(0.5,0.5)
		medal_sprite.play("galaxy")
		medal_label.text = "[color=SKY_BLUE][wave amp=15.0 freq=5.0 connected=1]Galaxy medal[/wave][/color]"
	elif medal == "Nebula":
		medal_sprite.scale = Vector2(0.5,0.5)
		medal_sprite.play("nebula")
		medal_label.text = "[color=FUCHSIA][tornado radius=2.0 freq=2.0 connected=1]Nebula medal[/tornado][/color]"
	elif medal == "Supernova":
		medal_sprite.scale = Vector2(0.5,0.5)
		medal_sprite.play("supernova")
		medal_label.text = "[color=RED][pulse freq=2.0 color=#ffffff40 ease=-2.0]Supernova medal[/pulse][/color]"
	else:
		medal_sprite.scale = Vector2(0.5,0.5)
		medal_sprite.play("Asteroid")
		medal_label.text = "[shake rate=20.0 level=1 connected=1]Asteroid medal[/shake]"
	
	if star_grid.get_child_count() > 0:
		var children = star_grid.get_children()
		for c in children:
			star_grid.remove_child(c)
			c.queue_free()
	
	var star_list = dict.get("Stars")
	for s in star_list:
		var node_instance = star_container.instantiate()
		star_grid.add_child(node_instance)
		if s:
			node_instance.set_collected()
	
	if dict.get("LeftEyeCollected"):
		eye_container_left.show()
	else:
		eye_container_left.hide()
		
	if dict.get("RightEyeCollected"):
		eye_container_right.show()
	else:
		eye_container_right.hide()
	


func _process(delta):
	indicator.visible = finished and !no_more_dialogue
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("UIConfirm")  or Input.is_action_just_pressed("UIConfirmC")) and !disable_dialogue:
		if finished:
			nextPhrase()
		else:
			planet_info.visible_characters = len(planet_info.text)
	if visible and Input.is_action_just_pressed("ui_down") and tab_container.current_tab != 2:
		begin_button.grab_focus()
		disable_dialogue = true
	if visible and Input.is_action_just_pressed("ui_up"):
		begin_button.release_focus()
		abort_button.release_focus()
		disable_dialogue = false

func _on_begin_button_button_up():
	await LevelTransition.fade_to_black()
	if not next_level is PackedScene: 
		await LevelTransition.fade_from_black()
	else: get_tree().change_scene_to_packed(next_level)
	#LevelTransition.fade_from_black()
	#get_tree().paused = false


func _on_abort_button_button_up():
	Globals.disable_input = true
	disable_input_timer.start()
	hide()
	get_tree().paused = false


func _on_disable_input_timer_timeout():
	Globals.disable_input = false


func _on_visibility_changed() -> void:
	if visible:
		tab_container.get_tab_bar().grab_focus()
		disable_dialogue = false


func _on_tab_container_tab_changed(tab: int) -> void:
	if tab == 0:
		disable_dialogue = false
	else: 
		disable_dialogue = true
