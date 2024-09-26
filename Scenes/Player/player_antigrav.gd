extends CharacterBody2D


@export var movement_data : PlayerMovementData 



@onready var animated_sprite = $AnimatedSprite
@onready var coyote_jump_timer = $"Coyote Jump Timer"
@onready var starting_position = global_position

# Get the gravity from the project settings to be synced with RigidBody nodes.
var air_jump = false
var just_wall_jumped = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var AntiGravityEnabled = false

func _physics_process(delta):
	apply_gravity(delta)

	handle_wall_jump()
	handle_jump()
	
	
	# Get the input direction and handle the movement/deceleration.
	var input_axis = Input.get_axis("ui_left", "ui_right")
	apply_acceleration(input_axis, delta)
	apply_air_accelaration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistance(input_axis, delta)
	
	update_animations(input_axis)
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	if Input.is_action_just_pressed("ui_accept"):
		movement_data = load("res://Resources/FasterMovement.tres")
	
	just_wall_jumped = false


func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		if AntiGravityEnabled:
			velocity.y -= gravity * delta * movement_data.gravity_scale
		else:
			velocity.y += gravity * delta * movement_data.gravity_scale



func handle_jump():
	
	if is_on_floor(): air_jump = true
	# Handle Jump.
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			if AntiGravityEnabled:
				velocity.y = movement_data.jump_velocity * -1
			else:
				velocity.y = movement_data.jump_velocity 

	elif not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < movement_data.jump_velocity/2:
			velocity.y = movement_data.jump_velocity/2
		if Input.is_action_just_pressed("ui_up") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity *0.8
			air_jump = false
			


func handle_wall_jump():
	if not is_on_wall_only():
		return
	var wall_normal = get_wall_normal() #vector that points away from the wall
	
	if Input.is_action_just_pressed("ui_up"):
		velocity.x = wall_normal.x*movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true
	
#	if Input.is_action_just_pressed("ui_up") and wall_normal == Vector2.RIGHT:
#		velocity.x = wall_normal.x*movement_data.speed
#		velocity.y = movement_data.jump_velocity

func apply_acceleration(input_axis, delta):
	if input_axis!=0 and is_on_floor():
		velocity.x = move_toward(velocity.x, movement_data.speed*input_axis, movement_data.accelaration*delta)
	
func apply_air_accelaration(input_axis, delta):
	if is_on_floor():
		return 
	if input_axis!=0:
		velocity.x = move_toward(velocity.x, movement_data.speed*input_axis, movement_data.air_accelaration*delta)

func apply_friction(input_axis, delta):
	if input_axis==0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction*delta)

func apply_air_resistance(input_axis, delta):
	if input_axis==0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance*delta)

func update_animations(input_axis):
	if input_axis!=0:
		if AntiGravityEnabled: 
			animated_sprite.flip_h = (input_axis>0)
		else:
			animated_sprite.flip_h = (input_axis<0)
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	
	if not is_on_floor():
		animated_sprite.play("jump")


func _on_hazard_detector_area_entered(area):
	global_position= starting_position


func _on_anti_grav_checker_body_entered(body):
	if body.is_in_group("Player"):

		if AntiGravityEnabled:
			AntiGravityEnabled = false
			up_direction.y=-1
			rotation_degrees=0
			position.y += 16
		else:
			AntiGravityEnabled = true
			up_direction.y=1
			rotation_degrees=180
			position.y -= 16
