extends CharacterBody2D

@export var movement_data : PlayerMovementData 

@onready var animated_sprite = $AnimatedSprite
@onready var coyote_jump_timer = $"Coyote Jump Timer"
@onready var starting_position = global_position
@onready var wall_jump_timer = $"Wall Jump Timer"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var air_jump = false
var just_wall_jumped = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_wall_normal = Vector2.ZERO
var GravityDirection = "Down"
var GravDrive = 1
var GravityX = false

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
	
	
	
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() # and velocity.y >= 0 
	if just_left_ledge:
		coyote_jump_timer.start()
	#if Input.is_action_just_pressed("ui_accept"):
	#	movement_data = load("res://Resources/FasterMovement.tres")
	
	just_wall_jumped = false
	var just_left_wall = was_on_wall and not is_on_wall_only()
	if just_left_wall:
		wall_jump_timer.start()
	update_animations(input_axis)

func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		if not GravityX:
			velocity.y += gravity * delta * movement_data.gravity_scale * GravDrive
			velocity.y = clamp(velocity.y, -600,600)
		else:
			velocity.x += gravity * delta * movement_data.gravity_scale * GravDrive
			velocity.x = clamp(velocity.x, -600,600)
			
func handle_jump():
	#print(coyote_jump_timer.time_left)
	if is_on_floor(): air_jump = true
	# Handle Jump.
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_pressed("ui_up"):
			if not GravityX: 
				velocity.y = movement_data.jump_velocity * GravDrive
			else:
				velocity.x = movement_data.jump_velocity * GravDrive
			coyote_jump_timer.stop()

	elif not is_on_floor():
		if Input.is_action_just_released("ui_up"):
			if not GravityX:
				if velocity.y < movement_data.jump_velocity/2: 
					velocity.y = movement_data.jump_velocity/2 
			else:
			
				if velocity.x < movement_data.jump_velocity/2: 
					velocity.x = movement_data.jump_velocity/2

		if Input.is_action_just_pressed("ui_up") and air_jump and not just_wall_jumped:
			if not GravityX:
				velocity.y = movement_data.jump_velocity *0.8 * GravDrive
			else:
				velocity.x = movement_data.jump_velocity *0.8 * GravDrive
			air_jump = false
			


func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0:
		return
	
	var wall_normal = get_wall_normal() #vector that points away from the wall
	
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
		
	if Input.is_action_just_pressed("ui_up"):
		
		if not GravityX:
			velocity.x = wall_normal.x*movement_data.speed 
			velocity.y = movement_data.jump_velocity * GravDrive
		else:
			velocity.y = wall_normal.y*movement_data.speed
			velocity.x = movement_data.jump_velocity*GravDrive
		just_wall_jumped = true
	
#	if Input.is_action_just_pressed("ui_up") and wall_normal == Vector2.RIGHT:
#		velocity.x = wall_normal.x*movement_data.speed
#		velocity.y = movement_data.jump_velocity

func apply_acceleration(input_axis, delta):
	if input_axis!=0 and is_on_floor():
		if not GravityX:
			velocity.x = move_toward(velocity.x, movement_data.speed*input_axis, movement_data.accelaration*delta)
		else: 
			velocity.y = move_toward(velocity.y, movement_data.speed*input_axis*-1*GravDrive, movement_data.accelaration*delta)


func apply_air_accelaration(input_axis, delta):
	if is_on_floor():
		return 
	if input_axis!=0:
		if not GravityX:
			velocity.x = move_toward(velocity.x, movement_data.speed*input_axis, movement_data.air_accelaration*delta)
		else:
			velocity.y = move_toward(velocity.y, movement_data.speed*input_axis*-1 * GravDrive, movement_data.air_accelaration*delta)
			
func apply_friction(input_axis, delta):
	if input_axis==0 and is_on_floor():
		if not GravityX:
			velocity.x = move_toward(velocity.x, 0, movement_data.friction*delta)
		else:
			velocity.y = move_toward(velocity.y, 0, movement_data.friction*delta)


func apply_air_resistance(input_axis, delta):
	if input_axis==0 and not is_on_floor():
		if not GravityX:
			velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance*delta)
		else:
			velocity.y = move_toward(velocity.y, 0, movement_data.air_resistance*delta)

func update_animations(input_axis):
	if input_axis!=0:
		if GravityDirection=="Up": 
			animated_sprite.flip_h = (input_axis>0)
		else:
			animated_sprite.flip_h = (input_axis<0)
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	
	if not is_on_floor():
		animated_sprite.play("jump")


func _on_hazard_detector_area_entered(area):
	get_tree().reload_current_scene()
#	if GravityDirection!="Down":
#		set_gravity_down()
#	global_position= starting_position
#	velocity = Vector2.ZERO


func set_gravity_down():
	if GravityDirection!="Down":
		set_up_direction(Vector2.UP)
		rotation_degrees=0
		position.y += 16
		GravDrive = 1
		GravityX = false
		GravityDirection="Down"


func set_gravity_up():
	if GravityDirection!="Up":
			set_up_direction(Vector2.DOWN)
			rotation_degrees=180
			if GravityDirection=="Down":
				position.y -= 16
			GravDrive = -1
			GravityX = false
			GravityDirection="Up"


func set_gravity_right():
	if GravityDirection!="Right":
		rotation_degrees = -90
		set_up_direction(Vector2.LEFT)
		GravityX = true
		GravDrive = 1
		if GravityDirection=="Left":
				position.x+=16
		GravityDirection="Right"

func set_gravity_left():
	if GravityDirection!="Left":
			rotation_degrees = 90
			set_up_direction(Vector2.RIGHT)
			GravityX = true
			GravDrive = -1
			if GravityDirection=="Right":
				position.x-=16
			GravityDirection="Left"

func set_spawn(new_position):
	starting_position = new_position
