extends OptionButton

func _ready() -> void:
	add_resolutions()
	update_button_values()

func add_resolutions():
	for r in ConfigFileHandler.resolutions:
		add_item(r)

func update_button_values():
	var window_size_string = str(get_window().size.x, "x", get_window().size.y);
	print(window_size_string)
	var resolution_index = ConfigFileHandler.resolutions.keys().find(window_size_string)
	selected = resolution_index

func _on_item_selected(index: int) -> void:
	var key = get_item_text(index)
	var value = (ConfigFileHandler.resolutions[key])
	get_window().size = value
	#get_window().set_content_scale_size(ConfigFileHandler.resolutions[key])
	ConfigFileHandler.center_window()
	ConfigFileHandler.save_video_settings("resolution", value)
