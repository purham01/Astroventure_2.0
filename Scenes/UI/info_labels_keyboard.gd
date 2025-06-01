extends HBoxContainer

@onready var confirm_sprite: AnimatedSprite2D = $ConfirmIcon/AnimKeySprite
@onready var back_sprite: AnimatedSprite2D = $BackIcon/AnimKeySprite

func _ready() -> void:
	ConfigFileHandler.controls_changed.connect(_set_sprites)
	_set_sprites()

func _set_sprites():
	var events = InputMap.action_get_events("UIConfirm")
	
	if events.size() > 0:
		_update_action_list_keyboard(confirm_sprite, events[0])
	
	events = InputMap.action_get_events("UIBack")
	
	if events.size() > 0:
		_update_action_list_keyboard(back_sprite, events[0])
		
	
func _update_action_list_keyboard(sprite,event):
	#print(event.as_text())
	var key_name = event.as_text().trim_suffix(" (Physical)")
	#button.find_child("LabelInput").text = key_name
	
	
	if key_name in ControlsSingleton.key_icons:
		sprite.play("keys")
		sprite.frame = ControlsSingleton.key_icons[key_name]
		
		
	elif key_name in ControlsSingleton.wide_key_icons:
		sprite.play("wide_keys")
		sprite.frame = ControlsSingleton.wide_key_icons[key_name]
	
	#else:
		#var key_label_instance = key_label_scene.instantiate()
		#h_box_container.add_child(key_label_instance)
		#key_label_instance.text = str(key_name)
