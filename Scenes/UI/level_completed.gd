extends ColorRect

@onready var next_level_button = %NextLevelButton
@onready var retry_button = %RetryButton
@onready var hearts = $CenterContainer/VBoxContainer/Hearts
@onready var time = $CenterContainer/VBoxContainer/Time
@onready var level_goal_time = $CenterContainer/VBoxContainer/LevelGoalTime
@onready var score = $CenterContainer/VBoxContainer/Score
@onready var deaths = $CenterContainer/VBoxContainer/Deaths
@onready var text_timer = $TextTimer
@onready var animation_player = $AnimationPlayer

signal retry()
signal next_level()

var player_death_counter := 0
var hearts_text = "Hearts collected %s/%s"
var deaths_text = "Deaths: %s"
var time_text = "Time: %s"
var goal_time_text = "Level goal time: %s"
var score_text = "Score: %s"

var heartsCollected
var heartsMax
var level_time
var level_best_time

func _ready():
	Events.player_dead.connect(increase_player_deaths)

func show_data(heartsCollectedTemp, heartsMaxTemp, levelTimeTemp, levelBestTimeTemp):
	heartsCollected =heartsCollectedTemp
	heartsMax = heartsMaxTemp
	level_time = levelTimeTemp
	level_best_time = levelBestTimeTemp
	
	hearts.text = hearts_text % [heartsCollected, heartsMax]
	deaths.text = deaths_text % [player_death_counter]
	time.text = time_text % [level_time]
	level_goal_time.text = goal_time_text % [level_best_time]
	score.text = score_text % [(calculate_score(heartsCollected, level_time, level_best_time))]
	
	show()
	retry_button.grab_focus()
	animation_player.play("show")
	await(animation_player.animation_finished)
	
	animation_player.play("show_hearts")
	await(animation_player.animation_finished)
	
	animation_player.play("show_deaths")
	await(animation_player.animation_finished)
	
	animation_player.play("show_time")
	await(animation_player.animation_finished)
	
	animation_player.play("show_goal_time")
	await(animation_player.animation_finished)
	
	animation_player.play("show_score")
	await(animation_player.animation_finished)

func calculate_score(heartsCollected, level_time, level_best_time):
	var score := 0.0
	print(level_time-level_best_time)
	score += heartsCollected*500 
	if level_time < level_best_time:
		score+=abs(level_time-level_best_time)*50
	
	return score

func increase_player_deaths():
	player_death_counter+=1


func _on_retry_button_pressed():
	retry.emit()


func _on_next_level_button_pressed():
	next_level.emit()
