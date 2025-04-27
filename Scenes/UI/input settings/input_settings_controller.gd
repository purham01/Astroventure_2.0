extends Control

@onready var input_button_scene = preload("res://Scenes/UI/input settings/input_button_controller.tscn")
@onready var action_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList
@onready var key_icon_scene = preload("res://Scenes/UI/input settings/key_icon_controller.tscn")
@onready var key_label_scene = preload("res://Scenes/UI/input settings/key_label.tscn")

@onready var reset_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ResetButton
@onready var scroll_container: ScrollContainer = %ScrollContainer

@onready var key_label_text: Label = $PanelContainer/PopUp/PanelContainer/VBoxContainer/KeyLabelText
@onready var pop_up: MarginContainer = $PanelContainer/PopUp
@onready var pop_up_timer: Timer = $PanelContainer/PopUp/PopUpTimer

var is_remapping = false
var action_to_remap = null
var remapping_button = null
var first_button : Button = null
var focused_button = null

var input_actions = {
	"MoveUpC": "Move up",
	"MoveLeftC": "Move left",
	"MoveDownC": "Move down",
	"MoveRightC": "Move right",
	"JumpC" : "Jump",
	"DashC" : "Dash",
	"ClimbC" : "Climb",
	"PauseC" : "Pause"
}

var button_icons = {
	"Joypad Button 2 (Left Action, Sony Square, Xbox X, Nintendo Y)" : 0,
	"Joypad Button 0 (Bottom Action, Sony Cross, Xbox A, Nintendo B)" : 1,
	"Joypad Button 3 (Top Action, Sony Triangle, Xbox Y, Nintendo X)" : 2,
	"Joypad Button 1 (Right Action, Sony Circle, Xbox B, Nintendo A)" : 3,
	"Joypad Button 4 (Back, Sony Select, Xbox Back, Nintendo -)" : 4,
	"Joypad Button 6 (Start, Xbox Menu, Nintendo +)" : 5,
	"Joypad Button 11 (D-pad Up)" : 6,
	"Joypad Button 12 (D-pad Down)" : 7,
	"Joypad Button 13 (D-pad Left)" : 8,
	"Joypad Button 14 (D-pad Right)" : 9,
	"Joypad Motion on Axis 4 (Joystick 2 X-Axis, Left Trigger, Sony L2, Xbox LT) with Value 1.00" : 10, 
	"Joypad Motion on Axis 5 (Joystick 2 Y-Axis, Right Trigger, Sony R2, Xbox RT) with Value 1.00" : 11,
	"Joypad Button 9 (Left Shoulder, Sony L1, Xbox LB)" : 12,
	"Joypad Button 10 (Right Shoulder, Sony R1, Xbox RB)" : 13
};

var stick_icons = {
	"Joypad Motion on Axis 1 (Left Stick Y-Axis, Joystick 0 Y-Axis) with Value -1.00" : 0,
	"Joypad Motion on Axis 0 (Left Stick X-Axis, Joystick 0 X-Axis) with Value -1.00" : 1,
	"Joypad Motion on Axis 1 (Left Stick Y-Axis, Joystick 0 Y-Axis) with Value 1.00" : 3,
	"Joypad Motion on Axis 0 (Left Stick X-Axis, Joystick 0 X-Axis) with Value 1.00" : 2,
	"Joypad Motion on Axis 3 (Right Stick Y-Axis, Joystick 1 Y-Axis) with Value -1.00" : 5,
	"Joypad Motion on Axis 2 (Right Stick X-Axis, Joystick 1 X-Axis) with Value -1.00" : 6,
	"Joypad Motion on Axis 3 (Right Stick Y-Axis, Joystick 1 Y-Axis) with Value 1.00" : 7,
	"Joypad Motion on Axis 2 (Right Stick X-Axis, Joystick 1 X-Axis) with Value 1.00" : 8,
}


func _ready() -> void:
	_load_keybindings_from_settings()
	_create_action_list()
	#first_button.grab_focus()


func _load_keybindings_from_settings():
	var keybindings = ConfigFileHandler.load_controller_buttons()
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
	
	first_button.focus_neighbor_top = first_button.get_path_to(reset_button)
	reset_button.focus_neighbor_bottom = reset_button.get_path_to(first_button)

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
			event is InputEventJoypadButton
			or event is InputEventJoypadMotion 
		):
			print("Adding action: ", action_to_remap)
			print("Keybind: ", event.as_text())
			#turn double click into single click
			#if event is InputEventMouseButton and event.double_click:
			#	event.double_click = false

			print(event)
			
			if event is InputEventJoypadMotion:
				if event.axis_value < 0.0:
					print("Value is less than")
					event.axis_value = -1.00
				elif event.axis_value > 0.0:
					print("value is greater than")
					event.axis_value = 1.00

			var events = InputMap.action_get_events(action_to_remap)
			var event_name = event.as_text()
			var action_found = false
			
			print(event_name)
			
			for e in events:
				if e.as_text() == event_name:
					action_found = true

			if !action_found:
				var action_to_remap_name = action_to_remap + "_" + str(events.size())
				#print("Action to remap name: ", action_to_remap_name)
				#print("Event: ", event)
				
				ConfigFileHandler.save_controller_button(action_to_remap_name, event)
				InputMap.action_add_event(action_to_remap, event)
				
				_update_action_list(remapping_button, event)
			
			else:
				print("Action already found")
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			pop_up.hide()
			accept_event()
	
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

			ConfigFileHandler.erase_controller_button(action)
			
			InputMap.action_erase_events(action)
			
			

func _update_action_list(button, event):
	
	var key_name = event.as_text()
	print(key_name)
	#button.find_child("LabelInput").text = key_name
	
	
	if key_name in button_icons:
		var key_icon_instance = key_icon_scene.instantiate()
		var key_anim_sprite = key_icon_instance.find_child("AnimKeySprite")
		button.find_child("keyIcons").add_child(key_icon_instance)
		key_anim_sprite.play("default")
		key_anim_sprite.frame = button_icons[key_name]
		
		
	elif key_name in stick_icons:
		var key_icon_instance = key_icon_scene.instantiate()
		var key_anim_sprite : AnimatedSprite2D = key_icon_instance.find_child("AnimKeySprite")
		button.find_child("keyIcons").add_child(key_icon_instance)
		key_anim_sprite.play("sticks")
		key_anim_sprite.frame = stick_icons[key_name]
		#print(key_anim_sprite.animation)
		#print(stick_icons[key_name])
		#print(key_anim_sprite.frame)

	else:
		var key_label_instance = key_label_scene.instantiate()
		button.find_child("keyIcons").add_child(key_label_instance)
		key_label_instance.text = str(key_name)
	


func _on_reset_button_button_up() -> void:
	ConfigFileHandler.load_default_controller_controls()
	first_button = null
	_load_keybindings_from_settings()
	_create_action_list()


func _on_pop_up_timer_timeout() -> void:
	pop_up.hide()
	is_remapping = false
	action_to_remap = null
	remapping_button = null
