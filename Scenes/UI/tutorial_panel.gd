extends VBoxContainer

@export var label_text : String = ""
@export var action : String = ""
@onready var label: Label = $Label
@onready var h_box_container: HBoxContainer = $HBoxContainer

@onready var key_icon_scene = preload("res://Scenes/UI/input settings/key_icon.tscn")
@onready var button_icon_scene = preload("res://Scenes/UI/input settings/key_icon_controller.tscn")
@onready var key_label_scene = preload("res://Scenes/UI/input settings/key_label.tscn")


func _ready():
	ConfigFileHandler.input_type_changed.connect(change_input_type)
	if ConfigFileHandler.input_type == 0:
		_create_action_list_keyboard()
	elif ConfigFileHandler.input_type == 1:
		_create_action_list_controller()
	label.text = label_text
	
func change_input_type():
	if ConfigFileHandler.input_type == 0:
		_create_action_list_keyboard()
	elif ConfigFileHandler.input_type == 1:
		_create_action_list_controller()


func _create_action_list_keyboard():
	#InputMap.load_from_project_settings()
	for item in h_box_container.get_children():
		item.queue_free()
		
		
	var action_name = action
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		for e in events:
			#input_label.text = e.as_text().trim_suffix(" (Physical)")
			_update_action_list_keyboard(e)

func _update_action_list_keyboard(event):
	#print(event.as_text())
	var key_name = event.as_text().trim_suffix(" (Physical)")
	#button.find_child("LabelInput").text = key_name
	
	
	if key_name in ControlsSingleton.key_icons:
		var key_icon_instance = key_icon_scene.instantiate()
		var key_anim_sprite = key_icon_instance.find_child("AnimKeySprite")
		h_box_container.add_child(key_icon_instance)
		key_anim_sprite.play("keys")
		key_anim_sprite.frame = ControlsSingleton.key_icons[key_name]
		
		
	elif key_name in ControlsSingleton.wide_key_icons:
		var key_icon_instance = key_icon_scene.instantiate()
		var key_anim_sprite = key_icon_instance.find_child("AnimKeySprite")
		h_box_container.add_child(key_icon_instance)
		key_anim_sprite.play("wide_keys")
		#print(key_anim_sprite.animation)
		#print(wide_key_icons[key_name])
		key_anim_sprite.frame = ControlsSingleton.wide_key_icons[key_name]
	
	else:
		var key_label_instance = key_label_scene.instantiate()
		h_box_container.add_child(key_label_instance)
		key_label_instance.text = str(key_name)

func _create_action_list_controller():
	#InputMap.load_from_project_settings()
	for item in h_box_container.get_children():
		item.queue_free()
		
	var action_name = action + "C"
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		for e in events:
			#input_label.text = e.as_text().trim_suffix(" (Physical)")
			_update_action_list_controller(e)

func _update_action_list_controller(event):
	
	var key_name = event.as_text()
	#print(key_name)
	#button.find_child("LabelInput").text = key_name
	
	
	if key_name in ControlsSingleton.button_icons:
		var key_icon_instance = button_icon_scene.instantiate()
		var key_anim_sprite = key_icon_instance.find_child("AnimKeySprite")
		h_box_container.add_child(key_icon_instance)
		key_anim_sprite.play("default")
		key_anim_sprite.frame = ControlsSingleton.button_icons[key_name]
		
		
	elif key_name in ControlsSingleton.stick_icons:
		var key_icon_instance = button_icon_scene.instantiate()
		var key_anim_sprite : AnimatedSprite2D = key_icon_instance.find_child("AnimKeySprite")
		h_box_container.add_child(key_icon_instance)
		key_anim_sprite.play("sticks")
		key_anim_sprite.frame = ControlsSingleton.stick_icons[key_name]
		#print(key_anim_sprite.animation)
		#print(stick_icons[key_name])
		#print(key_anim_sprite.frame)

	else:
		var key_label_instance = key_label_scene.instantiate()
		h_box_container.add_child(key_label_instance)
		key_label_instance.text = str(key_name)
