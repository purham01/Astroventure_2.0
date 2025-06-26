extends CharacterBody2D

@export var speed_default = 20
@export var speed_boost = 100
@export var rotation_speed = 1.5

@export var camera : Camera2D
@onready var animated_sprite = $AnimatedSprite

@onready var speed = speed_default
var rotation_direction = 0


func get_input():
	if ConfigFileHandler.input_type == 0:
		rotation_direction = Input.get_axis("ShipSteerLeft", "ShipSteerRight")
		velocity -= transform.y * Input.get_axis("ShipBack", "ShipForward") * speed
		if Input.is_action_pressed("ShipBoost"):
			speed = speed_boost
		else:
			speed = speed_default
	elif ConfigFileHandler.input_type == 1:
		rotation_direction = Input.get_axis("ShipSteerLeftC", "ShipSteerRightC")
		velocity -= transform.y * Input.get_axis("ShipBackC", "ShipForwardC") * speed
		if Input.is_action_pressed("ShipBoostC"):
			speed = speed_boost
		else:
			speed = speed_default


func handle_animations():
	if Input.is_action_pressed("ShipForwardC") or Input.is_action_pressed("ShipBackC") or Input.is_action_pressed("ShipForward") or Input.is_action_pressed("ShipBack"): 
		animated_sprite.play("fire")
		if Input.is_action_pressed("ShipBoost") or Input.is_action_pressed("ShipBoostC"):
			animated_sprite.play("boost")
	else:
		animated_sprite.play("default")

func _physics_process(delta):
	get_input()
	handle_animations()
	rotation += rotation_direction * rotation_speed * delta
	velocity *= 0.95
	move_and_slide()
