extends ColorRect

@onready var next_level_button = %NextLevelButton
@onready var retry_button = %RetryButton
@onready var stars: Label = $MarginContainer/Panel/HBoxContainer/Panel/LevelInfo/VBoxContainer/Stars
@onready var deaths: Label = $MarginContainer/Panel/HBoxContainer/Panel/LevelInfo/VBoxContainer/Deaths
@onready var time: Label = %Time
@onready var animation_player = $AnimationPlayer
@onready var leaderboard: Control = %LeaderboardUI
@onready var medal_sprite: AnimatedSprite2D = %MedalSprite
@onready var medal_label: RichTextLabel = %MedalLabel



@onready var star_destroyer_medal_info: HBoxContainer = %StarDestroyerMedalInfo
@onready var star_destroyer_label: Label = %StarDestroyerLabel
@onready var galaxy_label: Label = %GalaxyLabel
@onready var nebula_label: Label = %NebulaLabel
@onready var supernova_label: Label = %SupernovaLabel
@onready var new_best_time: Label = %NewBestTime

signal retry()
signal next_level()

var player_death_counter := 0
var hearts_text = "Stars collected %s/%s"
var deaths_text = "Deaths: %s"
var time_text = "Time: %s"

var heartsCollected
var heartsMax
var level_time
var level_best_time


var star_destroyer_medal_time = 40.0
var galaxy_medal_time = 60.0
var nebula_medal_time = 90.0
var supernova_medal_time = 120.0
var asteroid_medal_time = null


func _ready():
	Events.player_dead.connect(increase_player_deaths)
	

func show_data(heartsCollectedTemp, heartsMaxTemp, levelTimeTemp, new_best):
	heartsCollected = heartsCollectedTemp
	heartsMax = heartsMaxTemp
	level_time = levelTimeTemp
	
	stars.text = hearts_text % [heartsCollected, heartsMax]
	deaths.text = deaths_text % [player_death_counter]
	time.text = time_text % [level_time]
	
	star_destroyer_label.text += str(star_destroyer_medal_time) + "s"
	galaxy_label.text += str(galaxy_medal_time) + "s"
	nebula_label.text += str(nebula_medal_time) + "s"
	supernova_label.text += str(supernova_medal_time)+ "s"
	
	if levelTimeTemp < star_destroyer_medal_time:
		medal_sprite.play("black hole")
		star_destroyer_medal_info.show()
		medal_label.text = "[color=DARK_ORANGE][shake rate=20.0 level=3 connected=1]Star destroyer medal[/shake][/color]"
	elif levelTimeTemp < galaxy_medal_time:
		medal_sprite.play("galaxy")
		medal_label.text = "[color=SKY_BLUE][wave amp=15.0 freq=5.0 connected=1]Galaxy medal[/wave][/color]"
	elif levelTimeTemp < nebula_medal_time:
		medal_sprite.play("nebula")
		medal_label.text = "[color=FUCHSIA][tornado radius=2.0 freq=2.0 connected=1]Nebula medal[/tornado][/color]"
	elif levelTimeTemp < supernova_medal_time:
		medal_sprite.play("supernova")
		medal_label.text = "[color=RED][pulse freq=2.0 color=#ffffff40 ease=-2.0]Supernova medal[/pulse][/color]"
	else:
		medal_sprite.play("Asteroid")
		medal_label.text = "[shake rate=20.0 level=1 connected=1]Asteroid medal[/shake]"

	if new_best:
		new_best_time.show()
	
	show()
	retry_button.grab_focus()
	
	
	animation_player.play("show")
	await(animation_player.animation_finished)

	if levelTimeTemp < star_destroyer_medal_time:
		animation_player.play("show medal_star_destroyer")
	else:
		animation_player.play("show medal")
	
	
	
	#animation_player.play("show_hearts")
	#await(animation_player.animation_finished)
	#
	#animation_player.play("show_deaths")
	#await(animation_player.animation_finished)
	#
	#animation_player.play("show_time")
	#await(animation_player.animation_finished)

	

func increase_player_deaths():
	player_death_counter+=1


func _on_retry_button_pressed():
	retry.emit()


func _on_next_level_button_pressed():
	next_level.emit()
