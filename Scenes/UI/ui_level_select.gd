extends CanvasLayer

@onready var begin_button = %BeginButton
@onready var abort_button = %AbortButton
@onready var animation_player = $AnimationPlayer
@onready var planet = %Planet
@onready var planet_info = %planet_info
@onready var text_timer = $TextTimer
@onready var disable_input_timer = $DisableInputTimer
@onready var indicator = $Control/ColorRect/ColorRect/Indicator
@onready var planet_name_label = %planet_name
@onready var planet_stats = %planet_stats

@export var next_level: PackedScene


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
	match planet_name:
		PlanetNames.Mercury:
			planet_name_label.text = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 3.70\nTemp: 167°C\nDanger: [color=green]LOW[/color]"
			dialog = mercury_text
		PlanetNames.Venus:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 8.87\nTemp: 464°C\nDanger: [color=orange]MEDIUM[/color]"
			dialog = venus_text
		PlanetNames.Earth:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 9.80\nTemp: 15°C\nDanger: [color=green]LOW[/color]"
			dialog = earth_text
		PlanetNames.Mars:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 3.71\nTemp: -65°C\nDanger: [color=orange]MEDIUM[/color]"
			dialog = mars_text
		PlanetNames.Jupiter:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 24.79\nTemp: -110°C\nDanger: [color=red]HIGH[/color]"
			dialog = jupiter_text
		PlanetNames.Saturn:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 10.44\nTemp: -140°C\nDanger: [color=green]LOW[/color]"
			dialog = saturn_text
		PlanetNames.Uranus:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 8.87\nTemp: -195°C\nDanger: [color=red]HIGH[/color]"
			dialog = uranus_text
		PlanetNames.Neptune:
			planet_name_label.text  = str(PlanetNames.keys()[planet_name])
			planet_stats.text = "[center]Gravity: 11.15\nTemp: -200°C\nDanger: [color=orange]MEDIUM[/color]"
			dialog = neptune_text

	show()
	phraseNum = 0
	no_more_dialogue = false
	if(dialog):
		nextPhrase()

func _process(delta):
	indicator.visible = finished and !no_more_dialogue
	if Input.is_action_just_pressed("ui_accept") and !disable_dialogue:
		if finished:
			nextPhrase()
		else:
			planet_info.visible_characters = len(planet_info.text)
	if Input.is_action_just_pressed("ui_down"):
		begin_button.grab_focus()
		disable_dialogue = true
	if Input.is_action_just_pressed("ui_up"):
		begin_button.release_focus()
		abort_button.release_focus()
		disable_dialogue = false

func _on_begin_button_button_up():
	await LevelTransition.fade_to_black()
	if not next_level is PackedScene: get_tree().change_scene_to_file("res://Scenes/Screens/victory_screen.tscn")
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
