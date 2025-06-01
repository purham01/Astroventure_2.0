extends Control

@onready var start_game_button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var enter_name: LineEdit = %EnterName

@onready var main_menu_layer: CenterContainer = $MainMenuLayer

@onready var new_game_start_layer: Panel = $NewGameStartLayer
@onready var info_labels_keyboard: HBoxContainer = $InfoLabelsKeyboard
@onready var info_labels_controller: HBoxContainer = $InfoLabelsController
@onready var secondary_menu_container: MarginContainer = %SecondaryMenuContainer
@onready var info_labels_keyboard_enter_name: HBoxContainer = $InfoLabelsKeyboardEnterName
@onready var options_button: Button = %OptionsButton

var player_name = ""
var current_tab = main_menu_layer

func _ready():
	if FileAccess.file_exists("user://savegame.save"):
		continue_button.disabled = false
		continue_button.grab_focus()
	else:
		start_game_button.grab_focus()
	LevelTransition.fade_from_black()
	RenderingServer.set_default_clear_color(Color.BLACK)

	ConfigFileHandler.input_type_changed.connect(change_input_type)

func _input(event):
	if (event.is_action_pressed("UIBack") or event.is_action_pressed("UIBackC") ) and current_tab == secondary_menu_container:
		_on_back_button_pressed()

	if current_tab == new_game_start_layer and event.is_action_pressed("ui_cancel"):
		new_game_start_layer.hide()
		main_menu_layer.show()
		current_tab = main_menu_layer
		continue_button.grab_focus()
		enter_name.clear()
		info_labels_keyboard_enter_name.hide()
		change_input_type()

func _on_back_button_pressed():
	if !secondary_menu_container.previous_tabs.is_empty():
		secondary_menu_container._on_back_button_pressed()
		
	if secondary_menu_container.current_tab == secondary_menu_container.root_tab:
		current_tab = main_menu_layer
		options_button.grab_focus()

func change_input_type():
	if current_tab == new_game_start_layer:
		return
	if ConfigFileHandler.input_type == 0 and !info_labels_keyboard.visible:
		info_labels_keyboard.show()
		info_labels_controller.hide()
	elif ConfigFileHandler.input_type == 1 and !info_labels_controller.visible:
		info_labels_keyboard.hide()
		info_labels_controller.show()

func _on_start_game_pressed():
	main_menu_layer.hide()
	new_game_start_layer.show()
	enter_name.grab_focus()
	current_tab = new_game_start_layer
	info_labels_keyboard_enter_name.show()
	info_labels_controller.hide()
	info_labels_keyboard.hide()
	#await LevelTransition.fade_to_black_menu()
	#get_tree().change_scene_to_file("res://Scenes/Levels/Test_level.tscn")
	#LevelTransition.fade_from_black()
	pass
	


func _on_quit_pressed():
	get_tree().quit()


func _on_continue_button_button_up() -> void:
	await LevelTransition.fade_to_black_menu()
	get_tree().change_scene_to_file("res://Scenes/Levels/MapScreen.tscn")
	LevelTransition.fade_from_black()
	


func _on_options_button_pressed() -> void:
	current_tab = secondary_menu_container
	secondary_menu_container.previous_tabs.append([main_menu_layer, continue_button])
	secondary_menu_container.current_tab = secondary_menu_container.options_menu_tab
	secondary_menu_container.previous_tabs[secondary_menu_container.previous_tabs.size()-1][0].hide()
	
	secondary_menu_container.current_tab.show()
	secondary_menu_container.general_button.grab_focus()


func _on_enter_name_text_submitted(new_text: String) -> void:
	player_name = new_text
	
	Save.new_game(player_name)
	
	
	await Events.new_game_started
	await LevelTransition.fade_to_black_menu()
	get_tree().change_scene_to_file("res://Scenes/NewLevels/Earth.tscn")
	LevelTransition.fade_from_black()
