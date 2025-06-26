extends OptionButton

func _ready() -> void:
	add_settings()
	update_button_values()
	

func add_settings():
	for r in ConfigFileHandler.shader_options:
		add_item(r)

func update_button_values():
	var general_settings = ConfigFileHandler.load_general_settings()
	selected = general_settings.get("shader_setting")

func _on_item_selected(index: int) -> void:
	ShaderEffect.change_shader_settings(index)
	ConfigFileHandler.save_general_settings("shader_setting", index)
