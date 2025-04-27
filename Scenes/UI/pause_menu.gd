extends ColorRect

@onready var retry_button = %RetryButton
@onready var resume_button = %ResumeButton


#tabs
@onready var pause_menu_tab = %PauseMenuTab
@onready var options_menu_tab = %OptionsMenuTab
@onready var audio_options_tab: VBoxContainer = %AudioOptionsTab
@onready var video_menu_tab: VBoxContainer = %VideoMenuTab
@onready var input_settings: Control = $PanelContainer/MarginContainer/InputSettings
@onready var input_settings_controller: Control = $PanelContainer/MarginContainer/InputSettingsController

#audio
@onready var master_volume: HSlider = %MasterVolume
@onready var music_volume: HSlider = %MusicVolume
@onready var sfx_volume: HSlider = %SFXVolume
@onready var master_volume_value: Label = %MasterVolumeValue
@onready var music_volume_value: Label = %MusicVolumeValue
@onready var sfx_volume_value: Label = %SFXVolumeValue



#controls
@onready var info_labels_controller: HBoxContainer = $InfoLabelsController
@onready var info_labels_keyboard: HBoxContainer = $InfoLabelsKeyboard

signal retry()
signal main_menu()
signal map_screen()

var current_tab = null
var previous_tabs = []

var is_paused = false

func _ready() -> void:
	_load_options()
	current_tab = pause_menu_tab
	ConfigFileHandler.input_type_changed.connect(change_input_type)

func _load_options():
	var audio_settings = ConfigFileHandler.load_audio_settings()
	master_volume.value = audio_settings.master_volume
	music_volume.value = audio_settings.music_volume
	sfx_volume.value = audio_settings.sfx_volume

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
			get_tree().paused = true
			show()
			resume_button.grab_focus()
		else:
			get_tree().paused = false
			reset_tabs()
			hide()
		
	if event.is_action_pressed("UIBack") and get_tree().paused:
		_on_back_button_pressed()

func reset_tabs():
	current_tab.hide()
	pause_menu_tab.show()
	previous_tabs = []

func _on_retry_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_main_menu_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/Screens/main_menu.tscn")


func _on_resume_button_pressed():
	get_tree().paused = false
	hide()


func _on_map_screen_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Scenes/Levels/MapScreen.tscn")


func _on_back_button_pressed():
	if previous_tabs.is_empty():
		get_tree().paused = false
		hide()
		return
	current_tab.hide()
	current_tab = previous_tabs[previous_tabs.size()-1][0]
	previous_tabs[previous_tabs.size()-1][1].grab_focus()
	current_tab.show()
	previous_tabs.pop_back()
	


func _on_options_pressed():
	previous_tabs.append([pause_menu_tab, %Options])
	current_tab = options_menu_tab
	previous_tabs[previous_tabs.size()-1][0].hide()
	current_tab.show()
	%GeneralButton.grab_focus()

func _on_audio_button_button_up() -> void:
	previous_tabs.append([options_menu_tab, %AudioButton])
	current_tab = audio_options_tab
	options_menu_tab.hide()
	audio_options_tab.show()
	%MasterVolume.grab_focus()

func _on_video_button_button_up() -> void:
	previous_tabs.append([options_menu_tab, %VideoButton])
	current_tab = video_menu_tab
	options_menu_tab.hide()
	video_menu_tab.show()
	%WindowMode.grab_focus()

func _on_controls_button_button_up() -> void:
	previous_tabs.append([options_menu_tab, %ControlsButton])
	current_tab = input_settings
	options_menu_tab.hide()
	input_settings.show()
	input_settings.first_button.grab_focus()
	input_settings.scroll_container.scroll_vertical = 0



func _on_controls_button_2_button_up() -> void:
	previous_tabs.append([options_menu_tab, %ControlsButton2])
	current_tab = input_settings_controller
	options_menu_tab.hide()
	input_settings_controller.show()
	input_settings_controller.first_button.grab_focus()
	input_settings_controller.scroll_container.scroll_vertical = 0


func _on_master_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_settings("master_volume", master_volume.value)

func _on_music_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_settings("music_volume", music_volume.value)

func _on_sfx_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_settings("sfx_volume", sfx_volume.value)


func _on_master_volume_value_changed(value: float) -> void:
	master_volume_value.text = str(value*100) + "%"

func _on_music_volume_value_changed(value: float) -> void:
	music_volume_value.text = str(value*100) + "%"

func _on_sfx_volume_value_changed(value: float) -> void:
	sfx_volume_value.text = str(value*100) + "%"
