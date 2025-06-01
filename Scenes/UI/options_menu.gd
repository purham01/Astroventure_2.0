extends MarginContainer

@onready var options_menu_tab = %OptionsMenuTab
@onready var audio_options_tab: VBoxContainer = %AudioOptionsTab
@onready var video_menu_tab: VBoxContainer = %VideoMenuTab
@onready var input_settings: Control = %InputSettings
@onready var input_settings_controller: Control = %InputSettingsController
@onready var general_options: VBoxContainer = %GeneralOptions

#audio
@onready var master_volume: HSlider = %MasterVolume
@onready var music_volume: HSlider = %MusicVolume
@onready var sfx_volume: HSlider = %SFXVolume
@onready var master_volume_value: Label = %MasterVolumeValue
@onready var music_volume_value: Label = %MusicVolumeValue
@onready var sfx_volume_value: Label = %SFXVolumeValue

#general
@onready var camera_shake: HSlider = $GeneralOptions/Slider/CameraShake
@onready var camera_shake_value: Label = $GeneralOptions/Slider/CameraShakeValue
@onready var controller_vibration: HSlider = $"GeneralOptions/Slider2/Controller vibration"
@onready var controller_vibration_value: Label = $GeneralOptions/Slider2/ControllerVibrationValue
@onready var general_button: Button = %GeneralButton
@onready var show_tutorials: CheckButton = %"Show tutorials"
@onready var player_ghost: CheckButton = %PlayerGhost
@onready var shader_settings: OptionButton = $GeneralOptions/ShaderSettings

@onready var window_mode: OptionButton = %WindowMode
@onready var resolutions: OptionButton = %Resolutions


var current_tab = null
var previous_tabs = []

@export var root_tab : Control

func _ready() -> void:
	_load_options()
	current_tab = root_tab

func _load_options():
	var audio_settings = ConfigFileHandler.load_audio_settings()
	master_volume.value = audio_settings.master_volume
	music_volume.value = audio_settings.music_volume
	sfx_volume.value = audio_settings.sfx_volume
	
	camera_shake.value = ConfigFileHandler.camera_shake
	controller_vibration.value = ConfigFileHandler.controller_vibration
	camera_shake_value.text = str(ConfigFileHandler.camera_shake * 100) + "%"
	controller_vibration_value.text = str(ConfigFileHandler.controller_vibration * 100) + "%"
	
	show_tutorials.button_pressed = ConfigFileHandler.show_tutorials
	player_ghost.button_pressed = ConfigFileHandler.show_player_ghost
	
	

func _on_back_button_pressed():
	current_tab.hide()
	current_tab = previous_tabs[previous_tabs.size()-1][0]
	previous_tabs[previous_tabs.size()-1][1].grab_focus()
	current_tab.show()
	previous_tabs.pop_back()

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


func _on_general_button_button_up() -> void:
	previous_tabs.append([options_menu_tab, %GeneralButton])
	current_tab = general_options
	options_menu_tab.hide()
	general_options.show()
	shader_settings.grab_focus()


func _on_master_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_settings("master_volume", master_volume.value)

func _on_music_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_settings("music_volume", music_volume.value)
		
func _on_sfx_volume_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_settings("sfx_volume", sfx_volume.value)


func _on_master_volume_value_changed(value: float) -> void:
	master_volume_value.text = str(value*100) + "%"

func _on_music_volume_value_changed(value: float) -> void:
	music_volume_value.text = str(value*100) + "%"

func _on_sfx_volume_value_changed(value: float) -> void:
	sfx_volume_value.text = str(value*100) + "%"


func _on_camera_shake_value_changed(value: float) -> void:
	camera_shake_value.text = str(value*100) + "%"
	ConfigFileHandler.save_general_settings("camera_shake",value)
	ConfigFileHandler.camera_shake = value


func _on_controller_vibration_value_changed(value: float) -> void:
	controller_vibration_value.text = str(value*100) + "%"
	ConfigFileHandler.save_general_settings("controller_vibration",value)
	ConfigFileHandler.controller_vibration = value


func _on_player_ghost_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_general_settings("show_player_ghost", toggled_on)


func _on_show_tutorials_toggled(toggled_on: bool) -> void:
	ConfigFileHandler.save_general_settings("show_tutorials", toggled_on)


func _on_window_mode_item_selected(index: int) -> void:
	if index == 0 or index == 3:
		resolutions.disabled = true
	else:
		resolutions.disabled = false
