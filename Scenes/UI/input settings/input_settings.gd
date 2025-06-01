extends Control

@onready var input_button_scene = preload("res://Scenes/UI/input settings/input_button.tscn")
@onready var action_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList
@onready var key_icon_scene = preload("res://Scenes/UI/input settings/key_icon.tscn")
@onready var key_label_scene = preload("res://Scenes/UI/input settings/key_label.tscn")

@onready var key_label_text: Label = $PanelContainer/PopUp/PanelContainer/VBoxContainer/KeyLabelText
@onready var pop_up: MarginContainer = $PanelContainer/PopUp
@onready var pop_up_timer: Timer = $PanelContainer/PopUp/PopUpTimer
@onready var back_button: Button = $PanelContainer/MarginContainer/VBoxContainer/BackButton

@onready var reset_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ResetButton
@onready var scroll_container: ScrollContainer = %ScrollContainer

var is_remapping = false
var action_to_remap = null
var remapping_button = null
var first_button : Button = null
var focused_button = null

var input_actions = ControlsSingleton.input_actions

var key_icons = {
	"Escape" : 0,
	"F1" : 1,
	"F2" : 2,
	"F3" : 3,
	"F4" : 4,
	"F5" : 5,
	"F6" : 6,
	"F7" : 7,
	"F8" : 8,
	"F9" : 9,
	"F10" : 10,
	"F11" : 11,
	"F12" : 12,
	"AsciiCircum" : 13, 
	"1" : 14,
	"2" : 15,
	"3" : 16,
	"4" : 17,
	"5" : 18,
	"6" : 19,
	"7" : 20,
	"8" : 21,
	"9" : 22,
	"0" : 23,
	"NumberSign" : 24,
	"Equal" : 25,
	"Q" : 26,
	"W" : 27,
	"E" : 28,
	"R" : 29,
	"T" : 30,
	"Y" : 31,
	"U" : 32,
	"I" : 33,
	"O" : 34,
	"P" : 35,
	"BracketLeft" : 36,
	"BracketRight" : 37,
	"Backslash" : 38,
	"A" : 39,
	"S" : 40,
	"D" : 41,
	"F" : 42,
	"G" : 43,
	"H" : 44,
	"J" : 45,
	"K" : 46,
	"L" : 47,
	"Semicolon" : 48,
	"Apostrophe" : 49,
	"Z" : 50,
	"X" : 51,
	"C" : 52,
	"V" : 53,
	"B" : 54,
	"N" : 55,
	"M" : 56,
	"Comma" : 57,
	"Period" : 58,
	"Slash" : 59,
	"Left" : 60,
	"Down" : 61,
	"Up" : 62,
	"Right" : 63
};

var wide_key_icons = {
	"Tab" : 0,
	"CapsLock" : 1,
	"Shift" : 2,
	"Ctrl" : 3,
	"Alt" : 4,
	"Backspace" : 5,
	"Enter" : 6
}

var mouse_icons = {
	"Right Mouse Button" : 1,
	"Left Mouse Button" : 2
}

func _ready() -> void:
	_load_keybindings_from_settings()
	_create_action_list()
	#first_button.grab_focus()


func _load_keybindings_from_settings():
	var keybindings = ConfigFileHandler.load_keybindings()
	for action : String in keybindings.keys():
		var action_array = action.split("_")
		#print(action_array)
		if action_array[1] == "0":
			InputMap.action_erase_events(action_array[0])
		
		InputMap.action_add_event(action_array[0], keybindings[action])
	
func _create_action_list():
	#InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button : Button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		#var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			for e in events:
				#input_label.text = e.as_text().trim_suffix(" (Physical)")
				_update_action_list(button, e)
		
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		
		button.focus_entered.connect(_on_input_button_focus_entered.bind(button,action))
		button.focus_exited.connect(_on_input_button_focus_exited)
		if first_button == null: first_button = button

	first_button.focus_neighbor_top = first_button.get_path_to(back_button)
	back_button.focus_neighbor_bottom = back_button.get_path_to(first_button)

func _on_input_button_pressed(button, action):
	if !is_remapping:
		var events = InputMap.action_get_events(action)
		if events.size() >= 4:
			print("Action already has 4 keybinds")
			return
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		#button.find_child("LabelInput").text = "Press key to bind..."
		pop_up.show()
		pop_up_timer.start()
		key_label_text.text = input_actions[action]

func _on_input_button_focus_entered(button,action):
	#print("Button focused")
	focused_button = [button,action]
	#print(focused_button)

func _on_input_button_focus_exited():
	#print("Button unfocused")
	#print(focused_button)
	focused_button = null

func _input(event):
	if is_remapping:
		#print(event)
		if(
			event is InputEventKey
			#or (event is InputEventMouseButton && event.pressed)
		):
			#turn double click into single click
			#if event is InputEventMouseButton and event.double_click:
			#	event.double_click = false
			
			#InputMap.action_erase_events(action_to_remap)
			
			var events = InputMap.action_get_events(action_to_remap)
			var event_name = event.as_text()
			var action_found = false
			
			for e in events:
				if e.as_text() == event_name:
					action_found = true

			if !action_found:
				var action_to_remap_name = action_to_remap + "_" + str(events.size())
				#print("Action to remap name: ", action_to_remap_name)
				#print("Event: ", event)
				
				ConfigFileHandler.save_keybinding(action_to_remap_name, event)
				InputMap.action_add_event(action_to_remap, event)
				
				_update_action_list(remapping_button, event)
			
			else:
				print("Action already found")
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			pop_up.hide()
			accept_event()
			ConfigFileHandler.controls_changed.emit()
	
	else:
		if event.is_action_pressed("ClearKeybind") and focused_button != null:
			var button = focused_button[0]
			var action = focused_button[1]
			
			var keyIcons = button.find_child("keyIcons")
			
			#makivamo sve ikone
			for n in keyIcons.get_children():
				keyIcons.remove_child(n)
				n.queue_free()
			print("Removing all keybinds for ",action)
			
			
			
			ConfigFileHandler.erase_keybinding(action)
			
			InputMap.action_erase_events(action)
			
			

func _update_action_list(button, event):
	#print(event.as_text())
	var key_name = event.as_text().trim_suffix(" (Physical)")
	#button.find_child("LabelInput").text = key_name
	
	
	if key_name in key_icons:
		var key_icon_instance = key_icon_scene.instantiate()
		var key_anim_sprite = key_icon_instance.find_child("AnimKeySprite")
		button.find_child("keyIcons").add_child(key_icon_instance)
		key_anim_sprite.play("keys")
		key_anim_sprite.frame = key_icons[key_name]
		
		
	elif key_name in wide_key_icons:
		var key_icon_instance = key_icon_scene.instantiate()
		var key_anim_sprite = key_icon_instance.find_child("AnimKeySprite")
		button.find_child("keyIcons").add_child(key_icon_instance)
		key_anim_sprite.play("wide_keys")
		#print(key_anim_sprite.animation)
		#print(wide_key_icons[key_name])
		key_anim_sprite.frame = wide_key_icons[key_name]
	
	else:
		var key_label_instance = key_label_scene.instantiate()
		button.find_child("keyIcons").add_child(key_label_instance)
		key_label_instance.text = str(key_name)
	


func _on_reset_button_button_up() -> void:
	ConfigFileHandler.load_default_keyboard_controls()
	first_button = null
	_load_keybindings_from_settings()
	_create_action_list()
	ConfigFileHandler.controls_changed.emit()


func _on_pop_up_timer_timeout() -> void:
	pop_up.hide()
	is_remapping = false
	action_to_remap = null
	remapping_button = null


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
