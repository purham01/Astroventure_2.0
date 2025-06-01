extends Node2D

@onready var button: Node2D = $Button
@onready var key: Node2D = $Key
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var key_sprite: AnimatedSprite2D = $Key/Sprite2D
@onready var button_sprite: AnimatedSprite2D = $Button/Sprite2D

var can_interact = false
@export var level_codename = ""

var left_eye_inserted 
var right_eye_inserted 
var left_eye_collected 
var right_eye_collected 

func _ready() -> void:
	ConfigFileHandler.input_type_changed.connect(change_input_type)
	ConfigFileHandler.controls_changed.connect(_set_control_sprites)

func _set_control_sprites():
	var events = InputMap.action_get_events("Interact")
	
	if events.size() > 0:
		var key_name = events[0].as_text()
		if key_name in ControlsSingleton.button_icons:
			key_sprite.play("keys")
			key_sprite.frame = ControlsSingleton.button_icons[key_name]
		elif key_name in ControlsSingleton.stick_icons:
			key_sprite.play("wide_keys")
			key_sprite.frame = ControlsSingleton.stick_icons[key_name]
	
	events = InputMap.action_get_events("InteractC")
	
	if events.size() > 0:
		var key_name = events[0].as_text()
		if key_name in ControlsSingleton.button_icons:
			button_sprite.play("default")
			button_sprite.frame = ControlsSingleton.button_icons[key_name]
		elif key_name in ControlsSingleton.stick_icons:
			button_sprite.play("sticks")
			button_sprite.frame = ControlsSingleton.stick_icons[key_name]




func _update_action_list_controller(sprite, event):
	
	var key_name = event.as_text()
	#print(key_name)
	#button.find_child("LabelInput").text = key_name
	
	
	if key_name in ControlsSingleton.button_icons:
		sprite.frame = ControlsSingleton.button_icons[key_name]
		
		
	elif key_name in ControlsSingleton.stick_icons:
		sprite.frame = ControlsSingleton.stick_icons[key_name]

func change_input_type():
	if ConfigFileHandler.input_type == 0 and !key.visible:
		key.show()
		button.hide()
	else:
		key.hide()
		button.show()


func set_sprite():
		if left_eye_inserted and right_eye_inserted:
			animated_sprite_2d.frame = 3
		elif left_eye_inserted:
			animated_sprite_2d.frame = 1
		elif right_eye_inserted:
			animated_sprite_2d.frame = 2
		else:
			animated_sprite_2d.frame = 0

func _input(event: InputEvent) -> void:
	if can_interact and (event.is_action_pressed("Interact") or event.is_action_pressed("InteractC")):
		interact()

func interact():
	var dict : Dictionary = Save.save_data.get(level_codename)
	
	left_eye_inserted = dict.get("LeftEyeInserted")
	right_eye_inserted = dict.get("RightEyeInserted")
	left_eye_collected = dict.get("LeftEyeCollected")
	right_eye_collected = dict.get("RightEyeCollected")
	
	if left_eye_inserted and right_eye_inserted:
		Events.open_leaderboard.emit() 
	elif left_eye_collected and !left_eye_inserted:
		Events.inserted_left_eye.emit()
		dict.set("LeftEyeInserted",true)
		left_eye_inserted = true
		Save.save_data.set(level_codename, dict)
		Save.save_game()
		set_sprite()
	elif right_eye_collected and !right_eye_inserted:
		Events.inserted_right_eye.emit()
		dict.set("RightEyeInserted",true)
		right_eye_inserted = true
		Save.save_data.set(level_codename, dict)
		Save.save_game()
		set_sprite()
	
	if right_eye_inserted and left_eye_inserted:
		Events.emit_signal("enable_leaderboard_ghosts")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		can_interact = true
		
		if ConfigFileHandler.input_type == 0:
			key.show()
		else:
			button.show()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		can_interact = false
		key.hide()
		button.hide()
