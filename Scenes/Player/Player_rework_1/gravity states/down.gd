extends "gravity_state.gd"


func enter_state():
	Player.set_up_direction(Vector2.UP)
	Player.rotation_degrees=0
	if Player.prev_gs == GRAVITY_STATES.up:
			Player.position.y += 16

func gravity(delta):
	if not Player.is_on_floor():
		Player.velocity.y += get_my_gravity() * delta

func get_my_gravity():
	return Player.jump_gravity if Player.velocity.y < 0.0 else Player.fall_gravity

func _assign_animation(delta):
	if Player.movement_input.x != 0:
		Player.animated_sprite.flip_h = (Player.movement_input.x<0)

	if !Player.is_on_floor():
		Player.animated_sprite.play("jump")
	elif Player.movement_input.x != 0:
		Player.animated_sprite.play("run")
	else:
		Player.animated_sprite.play("idle")

func apply_acceleration(delta):
	if Player.movement_input.x !=0 and Player.is_on_floor():
		Player.velocity.x = move_toward(Player.velocity.x, Player.SPEED*Player.speed_multiplier*Player.movement_input.x, Player.ACCELARATION*Player.acceleration_multiplier*delta)
		#print("applying accellaration")

func apply_air_accelaration(delta):
	if Player.is_on_floor():
		return 
	if Player.movement_input.x !=0:
		Player.velocity.x = move_toward(Player.velocity.x, Player.SPEED*Player.speed_multiplier*Player.movement_input.x, Player.AIR_ACCELARATION*Player.acceleration_multiplier*delta)
		#print("applying air accellaration")

func apply_friction(delta):
	if Player.movement_input.x==0 and Player.is_on_floor():
		Player.velocity.x = move_toward(Player.velocity.x, 0, Player.FRICTION*Player.friction_multiplier*delta)
		#print("applying friction")

func apply_air_resistance(delta):
	if Player.is_on_floor():
		return 
	if Player.movement_input.x==0:
		Player.velocity.x = move_toward(Player.velocity.x, 0, Player.AIR_RESISTANCE*Player.friction_multiplier*delta)
		#print("applying air resistance")

func wall_jump():
	var wall_jump_velocity = Player.WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -Player.wall_direction
	Player.velocity = wall_jump_velocity
	#if Player.movement_input.x == 0:
		#Player.animated_sprite.flip_h = (Player.wall_direction>0)

func jump():
	Player.velocity.y = Player.max_jump_velocity
	Player.animated_sprite.scale = Vector2(Player.squish_x, Player.squish_y)

func variable_jump():
	if Input.is_action_just_released("Jump") and Player.velocity.y < Player.min_jump_velocity:
		Player.velocity.y = Player.min_jump_velocity

func slide_movement(delta):
	#Player.player_movement(delta)
	gravity(delta)
	Player.velocity.y *= Player.slide_friction

func climb_movement(delta):
	if Player.movement_input.y < 0:
		Player.velocity.y = -Player.climb_speed
		Player.current_stamina -= Player.climb_stamina * delta
	elif Player.movement_input.y > 0:
		Player.velocity.y = Player.climb_speed
	else:
		Player.velocity.y = 0
		Player.current_stamina -= Player.hold_stamina * delta

func climb_edge():
	Player.velocity.x += 50 * Player.last_direction.x
