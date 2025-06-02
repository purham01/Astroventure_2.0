extends ColorRect

@onready var retry_button = %RetryButton
@onready var resume_button = %ResumeButton
@onready var leaderboard_button: Button = %LeaderboardButton
@onready var leaderboard_ui: Control = %LeaderboardUI


#tabs
@onready var pause_menu_tab = %PauseMenuTab
@onready var secondary_menu_container: MarginContainer = $PanelContainer/SecondaryMenuContainer


#controls
@onready var info_labels_controller: HBoxContainer = $InfoLabelsController
@onready var info_labels_keyboard: HBoxContainer = $InfoLabelsKeyboard

@onready var options: Button = $PanelContainer/PauseMenuContainer/PauseMenuTab/Options

var level_codename = ""
var leaderboard_id = ""

signal retry()
signal main_menu()
signal map_screen()

var current_tab = pause_menu_tab

var is_paused = false

func _ready() -> void:
	ConfigFileHandler.input_type_changed.connect(change_input_type)
	Events.connect("open_leaderboard", open_leaderboard)
	await Events.level_setup_done
	if leaderboard_id != "" and level_codename != "":
		leaderboard_ui.level_codename = level_codename
		leaderboard_ui.leaderboard_id = leaderboard_id
		if Save.save_data.get(level_codename).get("BestTime") != 0.0:
			leaderboard_button.disabled = false

			
func _button_pressed_sfx():
	FmodBanks.select.play()

func open_leaderboard():
	get_tree().paused = true
	_on_leaderboard_button_pressed()
	show()

func change_input_type():
	if ConfigFileHandler.input_type == 0 and !info_labels_keyboard.visible:
		info_labels_keyboard.show()
		info_labels_controller.hide()
	elif ConfigFileHandler.input_type == 1 and !info_labels_controller.visible:
		info_labels_keyboard.hide()
		info_labels_controller.show()

func _input(event):
	if event.is_action_pressed("Pause") or event.is_action_pressed("PauseC"):
		print("Pause")
		if visible == false:
			FmodBanks.pause.play()
			get_tree().paused = true
			show()
			resume_button.grab_focus()
		else:
			FmodBanks.unpause.play()
			get_tree().paused = false
			reset_tabs()
			hide()
		
	if (event.is_action_pressed("UIBack") or event.is_action_pressed("UIBackC")) and get_tree().paused:
		_on_back_button_pressed()
		

func reset_tabs():
	secondary_menu_container.current_tab.hide()
	leaderboard_ui.hide()
	current_tab = pause_menu_tab
	pause_menu_tab.show()
	secondary_menu_container.previous_tabs = []

func _on_back_button_pressed():
	if current_tab == leaderboard_ui:
		FmodBanks.cancel.play()
		leaderboard_ui.hide()
		pause_menu_tab.show()
		current_tab = pause_menu_tab
		leaderboard_button.grab_focus()
	elif secondary_menu_container.previous_tabs.is_empty():
		get_tree().paused = false
		hide()
		return
	else: 
		secondary_menu_container._on_back_button_pressed()

func _on_retry_button_pressed():
	_button_pressed_sfx()
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_button_pressed():
	_button_pressed_sfx()
	get_tree().quit()


func _on_main_menu_button_pressed():
	_button_pressed_sfx()
	get_tree().paused = false
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/Screens/main_menu.tscn")
	

func _on_resume_button_pressed():
	_button_pressed_sfx()
	get_tree().paused = false
	hide()


func _on_map_screen_button_pressed():
	_button_pressed_sfx()
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/Levels/MapScreen.tscn")

func _on_options_pressed():
	_button_pressed_sfx()
	secondary_menu_container.previous_tabs.append([pause_menu_tab, options])
	secondary_menu_container.current_tab = secondary_menu_container.options_menu_tab
	secondary_menu_container.previous_tabs[secondary_menu_container.previous_tabs.size()-1][0].hide()
	
	secondary_menu_container.current_tab.show()
	secondary_menu_container.general_button.grab_focus()


func _on_leaderboard_button_pressed() -> void:
	_button_pressed_sfx()
	current_tab = leaderboard_ui
	leaderboard_ui.score_list.grab_focus()
	leaderboard_ui.show()
	pause_menu_tab.hide()
	
