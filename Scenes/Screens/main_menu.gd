extends CenterContainer

@onready var start_game_button = %StartGameButton


func _ready():
	LevelTransition.fade_from_black()
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_game_button.grab_focus()
	
	
	

func _on_start_game_pressed():
	await LevelTransition.fade_to_black_menu()
	get_tree().change_scene_to_file("res://Scenes/Levels/LevelEarthv2.tscn")
	LevelTransition.fade_from_black()


func _on_quit_pressed():
	get_tree().quit()


func _on_continue_button_button_up() -> void:
	await LevelTransition.fade_to_black_menu()
	get_tree().change_scene_to_file("res://Scenes/Levels/MapScreen.tscn")
	LevelTransition.fade_from_black()
	
