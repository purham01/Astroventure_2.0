extends HBoxContainer

@onready var confirm_sprite: AnimatedSprite2D = $ConfirmIcon/AnimKeySprite
@onready var back_sprite: AnimatedSprite2D = $BackIcon/AnimKeySprite

func _ready() -> void:
	ConfigFileHandler.controls_changed.connect(_set_sprites)
	_set_sprites()



func _set_sprites():
	var events = InputMap.action_get_events("UIConfirmC")
	
	if events.size() > 0:
		_update_action_list_controller(confirm_sprite, events[0])
	
	events = InputMap.action_get_events("UIBackC")
	
	if events.size() > 0:
		_update_action_list_controller(back_sprite, events[0])

func _update_action_list_controller(sprite, event):
	
	var key_name = event.as_text()
	#print(key_name)
	#button.find_child("LabelInput").text = key_name
	
	
	if key_name in ControlsSingleton.button_icons:
		sprite.play("default")
		sprite.frame = ControlsSingleton.button_icons[key_name]
		
		
	elif key_name in ControlsSingleton.stick_icons:
		sprite.play("sticks")
		sprite.frame = ControlsSingleton.stick_icons[key_name]

#
	#else:
		#var key_label_instance = key_label_scene.instantiate()
		#h_box_container.add_child(key_label_instance)
		#key_label_instance.text = str(key_name)
