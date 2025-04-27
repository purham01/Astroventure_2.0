extends "gravity_state.gd"


func enter_state():
	Player.set_up_direction(Vector2.UP)
	Player.rotation_degrees=0
	if Player.prev_gs == GRAVITY_STATES.up:
			Player.position.y += 16

func gravity(delta):
	if not Player.is_on_floor():
		var mult = .5 if abs(Player.velocity.y) < Player.half_grav_threshhold and (Input.is_action_pressed("Jump") or Input.is_action_pressed("JumpC")) else 1.0
		
		Player.velocity.y = move_toward(Player.velocity.y, Player.max_fall, get_my_gravity() * mult * delta)

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
		Player.velocity.x = move_toward(Player.velocity.x, Player.SPEED*Player.terrain_sm.speed_multiplier*sign(Player.movement_input.x), Player.ACCELARATION*Player.terrain_sm.acceleration_multiplier*delta)
		#print("applying accellaration")

func apply_air_accelaration(delta):
	if Player.is_on_floor():
		return 
	if Player.movement_input.x !=0:
		Player.velocity.x = move_toward(Player.velocity.x, Player.SPEED*Player.terrain_sm.speed_multiplier*sign(Player.movement_input.x), Player.AIR_ACCELARATION*Player.terrain_sm.acceleration_multiplier*delta)
		#print("applying air accellaration")

func apply_friction(delta):
	if Player.movement_input.x==0 and Player.is_on_floor():
		Player.velocity.x = move_toward(Player.velocity.x, 0, Player.FRICTION*Player.terrain_sm.friction_multiplier*delta)
		#print("applying friction")

func apply_air_resistance(delta):
	if Player.is_on_floor():
		return 
	if Player.movement_input.x==0:
		Player.velocity.x = move_toward(Player.velocity.x, 0, Player.AIR_RESISTANCE*Player.terrain_sm.friction_multiplier*delta)
		#print("applying air resistance")

func wall_jump():
	var wall_jump_velocity
	
	if Player.movement_input.x != 0:
		wall_jump_velocity = Player.WALL_JUMP_VELOCITY
	else:
		wall_jump_velocity = Player.WALL_JUMP_VELOCITY_NEUTRAL
		
	wall_jump_velocity.x *= -Player.wall_direction
	Player.velocity = wall_jump_velocity


func jump():
	Player.velocity.x += Player.jump_h_boost * Player.movement_input.x;
	Player.velocity.y = Player.max_jump_velocity
	Player.animated_sprite.scale = Vector2(Player.squish_x, Player.squish_y)

func variable_jump():
	if  (Input.is_action_just_released("Jump") or Input.is_action_just_released("JumpC")) and Player.velocity.y < Player.min_jump_velocity:
		Player.velocity.y = Player.min_jump_velocity

func slide_movement(delta):
	#Player.player_movement(delta)
	Player.velocity.y = Player.slide_down_speed

func climb_movement(delta):
	if Player.movement_input.y < 0:
		Player.velocity.y = Player.climb_up_speed
		Player.current_stamina -= Player.climb_stamina * delta
	elif Player.movement_input.y > 0:
		Player.velocity.y = Player.climb_down_speed
	else:
		Player.velocity.y = 0
		Player.current_stamina -= Player.hold_stamina * delta

func climb_edge():
	Player.velocity.y = -120
	await get_tree().create_timer(0.05).timeout
	Player.velocity.x = 100 * Player.last_direction.x
	

func attempt_correction(amount: int):
	var delta = get_physics_process_delta_time()
	if Player.velocity.y < 0 and Player.test_move(Player.global_transform, Vector2(0, Player.velocity.y*delta)):
		for i in range(1, amount+1):
			for j in [-1.0, 1.0]:
				if !Player.test_move(Player.global_transform.translated(Vector2(i*j, 0)), Vector2(0, Player.velocity.y*delta)):
					Player.translate(Vector2(i*j, 0))
					Player.global_position.x = round(Player.global_position.x/Globals.UNIT_SIZE)*Globals.UNIT_SIZE - 2.79 * j
					if Player.velocity.x * j < 0: 
						Player.velocity.x = 0
						return

func vertical_boost():
	Player.change_state(Player.STATES.transition)
	Player.velocity.x = 0
	Player.velocity.y = -250

func jump_pad():
	Player.velocity.y = -325
	Player.terrain_sm.instant_reset_movement_values()
	Player.can_dash = true

func velocity_y_less_than():
	if Player.velocity.y < 0:
		return true
	else:
		return false

func velocity_y_greater_than():
	if Player.velocity.y > 0:
		return true
	else:
		return false

func velocity_x_equals():
	if Player.velocity.x == 0:
		return true
	else:
		return false
