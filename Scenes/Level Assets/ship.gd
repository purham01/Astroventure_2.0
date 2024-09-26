extends RigidBody2D

@export var thrust = Vector2(0, -500)
@export var torque = 500
@onready var animated_sprite = $AnimatedSprite


func _integrate_forces(state):
	if Input.is_action_pressed("ui_up"):
		state.apply_force(thrust.rotated(rotation))
		animated_sprite.play("fire")
	elif Input.is_action_pressed("ui_down"):
		state.apply_force(-thrust.rotated(rotation))
		animated_sprite.play("fire")
	else:
		state.apply_force(Vector2())
		animated_sprite.play("default")
		
	var rotation_direction = 0
	if Input.is_action_pressed("ui_right"):
		rotation_direction += 1
	if Input.is_action_pressed("ui_left"):
		rotation_direction -= 1
	state.apply_torque(rotation_direction * torque)
