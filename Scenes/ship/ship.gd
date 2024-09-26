extends CharacterBody2D

@export var speed_default = 20
@export var speed_boost = 100
@export var rotation_speed = 1.5

@export var camera : Camera2D
@onready var animated_sprite = $AnimatedSprite

@onready var speed = speed_default
var rotation_direction = 0


func get_input():
	rotation_direction = Input.get_axis("ui_left", "ui_right")
	velocity -= transform.y * Input.get_axis("ui_down", "ui_up") * speed
	if Input.is_action_pressed("boost"):
		speed = speed_boost
	else:
		speed = speed_default


func handle_animations():
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		animated_sprite.play("fire")
		if Input.is_action_pressed("boost"):
			animated_sprite.play("boost")
	else:
		animated_sprite.play("default")

func _physics_process(delta):
	get_input()
	handle_animations()
	rotation += rotation_direction * rotation_speed * delta
	velocity *= 0.95
	move_and_slide()

