extends OptionButton

func _ready() -> void:
	add_resolutions()
	update_button_values()
	

func add_resolutions():
	for r in ConfigFileHandler.window_modes:
		add_item(r)

func update_button_values():
	var video_settings = ConfigFileHandler.load_video_settings()
	selected = video_settings.get("window_mode")

func _on_item_selected(index: int) -> void:
	ConfigFileHandler.change_window_mode(index)
	ConfigFileHandler.save_video_settings("window_mode", index)
	
