extends Node

@onready var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.cfg"

signal input_type_changed

var resolutions = {
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2560,1440),
	"1920x1080": Vector2i(1920,1080),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1440x900": Vector2i(1440,900),
	"1600x900": Vector2i(1600,900),
	"1024x600": Vector2i(1024,600),
	"960x540": Vector2i(960,540),
	"640x320": Vector2i(640,320),
	"320x180": Vector2i(320,180)
}

var window_modes = [
	"Fullscreen",
	"Windowed",
	"Borderless Window",
	"Borderless Fullscreen"
]

var input_type = 0

func _ready() -> void:
	_load_settings()

func _input(event: InputEvent) -> void:
	if  input_type != 0 and event is InputEventKey :
		input_type = 0
		input_type_changed.emit()
	elif input_type == 0 and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		input_type = 1
		input_type_changed.emit()

func _load_settings():
	var err = config.load(SETTINGS_FILE_PATH)
	print("Loading settings")
	
	if err != OK:
		print("Failed to load")
		_load_default_settings()
		
		return
	else:
		print("Loaded settings")

func _load_default_settings():
	load_default_keyboard_controls()
	load_default_controller_controls()
	
	print(DisplayServer.screen_get_size())
	
	config.set_value("general", "vibration", 2)
	config.set_value("general", "camera_shake", 2)
	
	config.set_value("video", "window_mode", 0)
	config.set_value("video", "resolution", DisplayServer.screen_get_size())
	
	config.set_value("audio", "master_volume", 0.75)
	config.set_value("audio", "music_volume", 0.75)
	config.set_value("audio", "sfx_volume", 0.75)
	
	config.save(SETTINGS_FILE_PATH)
	print("Loaded default settings")

func load_default_keyboard_controls():
	config.erase_section("keybindings")
	
	config.set_value("keybindings", "MoveLeft_0", "A")
	config.set_value("keybindings", "MoveLeft_1", "Left")
	config.set_value("keybindings", "MoveRight_0", "D")
	config.set_value("keybindings", "MoveRight_1", "Right")
	config.set_value("keybindings", "MoveUp_0", "W")
	config.set_value("keybindings", "MoveUp_1", "Up")
	config.set_value("keybindings", "MoveDown_0", "S")
	config.set_value("keybindings", "MoveDown_1", "Down")
	config.set_value("keybindings", "Jump_0", "J")
	config.set_value("keybindings", "Climb_0", "K")
	config.set_value("keybindings", "Dash_0", "L")
	config.set_value("keybindings", "Pause_0", "Escape")
	
	config.save(SETTINGS_FILE_PATH)

func load_default_controller_controls():
	config.erase_section("controller")
	
	config.set_value("controller", "MoveLeftC_0", "Joypad Motion on Axis 0 (Left Stick X-Axis, Joystick 0 X-Axis) with Value -1.00")
	config.set_value("controller", "MoveLeftC_1", "Joypad Button 13 (D-pad Left)")
	config.set_value("controller", "MoveRightC_0", "Joypad Motion on Axis 0 (Left Stick X-Axis, Joystick 0 X-Axis) with Value 1.00")
	config.set_value("controller", "MoveRightC_1", "Joypad Button 14 (D-pad Right)")
	config.set_value("controller", "MoveUpC_0", "Joypad Motion on Axis 1 (Left Stick Y-Axis, Joystick 0 Y-Axis) with Value -1.00")
	config.set_value("controller", "MoveUpC_1", "Joypad Button 11 (D-pad Up)")
	config.set_value("controller", "MoveDownC_0", "Joypad Motion on Axis 1 (Left Stick Y-Axis, Joystick 0 Y-Axis) with Value 1.00")
	config.set_value("controller", "MoveDownC_1", "Joypad Button 12 (D-pad Down)")
	config.set_value("controller", "JumpC_0", "Joypad Button 0 (Bottom Action, Sony Cross, Xbox A, Nintendo B)")
	config.set_value("controller", "JumpC_1", "Joypad Button 3 (Top Action, Sony Triangle, Xbox Y, Nintendo X)")
	config.set_value("controller", "ClimbC_0", "Joypad Button 9 (Left Shoulder, Sony L1, Xbox LB)")
	config.set_value("controller", "ClimbC_1", "Joypad Button 10 (Right Shoulder, Sony R1, Xbox RB)")
	config.set_value("controller", "ClimbC_2", "Joypad Motion on Axis 4 (Joystick 2 X-Axis, Left Trigger, Sony L2, Xbox LT) with Value 1.00")
	config.set_value("controller", "ClimbC_3", "Joypad Motion on Axis 5 (Joystick 2 Y-Axis, Right Trigger, Sony R2, Xbox RT) with Value 1.00")
	config.set_value("controller", "DashC_0", "Joypad Button 2 (Left Action, Sony Square, Xbox X, Nintendo Y)")
	config.set_value("controller", "DashC_1", "Joypad Button 1 (Right Action, Sony Circle, Xbox B, Nintendo A)")
	config.set_value("controller", "PauseC_0", "Joypad Button 6 (Start, Xbox Menu, Nintendo +)")
	
	config.save(SETTINGS_FILE_PATH)

func save_video_settings(key : String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_settings():
	var video_settings = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings

func save_audio_settings(key : String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var video_settings = {}
	for key in config.get_section_keys("audio"):
		video_settings[key] = config.get_value("audio", key)
	return video_settings

func save_keybinding(action : StringName, event: InputEvent):
	print("Saving keybinding")
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton: 
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybindings", action, event_str)
	config.save(SETTINGS_FILE_PATH)


func save_controller_button(action : StringName, event: InputEvent):
	print("Saving controller button")
	var event_str = event.as_text()
	#if event is InputEventJoypadButton:
		#event_str 
	#elif event is InputEventJoypadMotion: 
		#event_str 
	
	config.set_value("controller", action, event_str)
	config.save(SETTINGS_FILE_PATH)

func erase_keybinding(action):
	var events = InputMap.action_get_events(action)
	var i = 0
	
	print(events)
	
	for e in events:
		var erase = action +"_"+ str(i)
		print(erase)
		ConfigFileHandler.config.erase_section_key("keybindings", erase)
		i+=1
		
	config.save(SETTINGS_FILE_PATH)

func erase_controller_button(action):
	var events = InputMap.action_get_events(action)
	var i = 0
	
	print(events)
	
	for e in events:
		var erase = action +"_"+ str(i)
		print(erase)
		ConfigFileHandler.config.erase_section_key("controller", erase)
		i+=1
		
	config.save(SETTINGS_FILE_PATH)

func load_keybindings():
	var keybindings = {}
	var keys = config.get_section_keys("keybindings")
	for key in keys:
		var input_event
		var event_str = config.get_value("keybindings", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
	
		keybindings[key] = input_event

	return keybindings

func load_controller_buttons():
	var keybindings = {}
	var keys = config.get_section_keys("controller")
	for key in keys:
		var input_event
		var event_str : String = config.get_value("controller", key)
		
		print("")
		print("Loading keybind: ", event_str)
		
		if event_str.contains("Motion"):
			input_event = InputEventJoypadMotion.new()
			var axis = event_str.substr(event_str.find("Axis") + 5, 1)
			var axis_value = event_str.substr(event_str.find("Value") + 6)
			print("Axis: ",axis)
			print("Axis value: ",axis_value)
			input_event.axis = int(axis)
			input_event.axis_value = float(axis_value) 
		else:
			input_event = InputEventJoypadButton.new()
			var button_index = event_str.substr(event_str.find("Button") + 7, 2)
			print("Button index: ",button_index)
			input_event.button_index = int(button_index)
	
		keybindings[key] = input_event

	return keybindings


func center_window():
	var screen_center = DisplayServer.screen_get_position( ) + DisplayServer.screen_get_size() / 2;
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size / 2)

func change_window_mode(index):
	match index:
		0: #fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: #windowed borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: #fullscreen borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
