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
	
	show()
	retry_button.grab_focus()
	animation_player.play("show")
	await(animation_player.animation_finished)
	show_heart_label()
#	hearts.text += str(heartsCollected)+"/"+str(heartsMax)
#	deaths.text = player_death_counter
#	time.text += str(level_time)
#	level_goal_time.text += str(level_best_time)
#	score.text += str(calculate_score(heartsCollected, level_time, level_best_time))


func show_heart_label():
	text_timer.wait_time = 1/heartsCollected
	hearts.text = hearts_text % [0,heartsMax]
	animation_player.play("show_hearts")
	await(animation_player.animation_finished)
	for i in heartsCollected:
		hearts.text = hearts_text % [i+1,heartsMax]
		text_timer.start()
		await(text_timer.timeout)
	show_death_label()

func show_death_label():
	text_timer.wait_time = 0.05 if player_death_counter==0 else 1/player_death_counter
	deaths.text = deaths_text % [0]
	animation_player.play("show_deaths")
	await(animation_player.animation_finished)
	for i in player_death_counter:
		deaths.text = deaths_text % [i+1]
		text_timer.start()
		await(text_timer.timeout)
	show_time_labels()

func show_time_labels():
	text_timer.wait_time = 0.05
	time.text =time_text % [level_time]
	animation_player.play("show_time")
	await(animation_player.animation_finished)
	
	level_goal_time.text = goal_time_text % [level_best_time]
	animation_player.play("show_goal_time")
	await(animation_player.animation_finished)
	
	show_score_label()

func show_score_label():
	var final_score = calculate_score(heartsCollected, level_time, level_best_time)
	var score_temp := 0.0
	#text_timer.wait_time = 0.01
	score.text = score_text % [0]
	animation_player.play("show_score")
	await(animation_player.animation_finished)
	text_timer.wait_time = 0.01 if final_score==0 else 1/final_score
	while score_temp<final_score:
		if score_temp>final_score:
			score_temp = final_score
		score.text = score_text % [score_temp]
		score_temp += 50
		text_timer.start()
		await(text_timer.timeout)

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
