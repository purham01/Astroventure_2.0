extends "gravity_state.gd"

func enter_state():
	if !Player.playerDead:
		Player.change_state(Player.STATES.gravity_transition)
		await Events.enter_portal
	Player.rotation_degrees = 270
	Events.emit_signal("change_gravity", 270)
	Player.set_up_direction(Vector2.LEFT)
	Player.dash_particles.process_material.gravity = Vector3(9.8, 0.0, 0.0)
	Player.slide_particles_left.process_material.gravity = Vector3(9.8, 0.0, 0.0)
	Player.slide_particles_right.process_material.gravity = Vector3(9.8, 0.0, 0.0)
	#if Player.prev_gs == GRAVITY_STATES.left:
	#	Player.position.x+=16
	
	#Player.velocity.x += 200

func gravity(delta):
	if not Player.is_on_floor():
		var mult = .5 if abs(Player.velocity.x) < Player.half_grav_threshhold and (Input.is_action_pressed("Jump") or Input.is_action_pressed("JumpC")) else 1.0
		
		Player.velocity.x = move_toward(Player.velocity.x, Player.max_fall, get_my_gravity() * mult * delta)

func get_my_gravity():
	return Player.jump_gravity if Player.velocity.x < 0.0 else Player.fall_gravity

func _assign_animation(delta):
	if Player.movement_input.x != 0 and Player.current_state != Player.STATES.climb:
		Player.animated_sprite.flip_h = (Player.last_direction.x<0)
		

func apply_acceleration(delta):
	if Player.movement_input.x !=0 and Player.is_on_floor():
		Player.velocity.y = move_toward(Player.velocity.y, -Player.SPEED*Player.terrain_sm.speed_multiplier*sign(Player.movement_input.x), Player.ACCELARATION*Player.terrain_sm.acceleration_multiplier*delta)
		#print("applying accellaration")

func apply_air_accelaration(delta):
	if Player.is_on_floor():
		return 
	if Player.movement_input.x !=0:
		Player.velocity.y = move_toward(Player.velocity.y, -Player.SPEED*Player.terrain_sm.speed_multiplier*sign(Player.movement_input.x), Player.AIR_ACCELARATION*Player.terrain_sm.acceleration_multiplier*delta)
		#print("applying air accellaration")

func apply_friction(delta):
	if Player.movement_input.x==0 and Player.is_on_floor():
		Player.velocity.y = move_toward(Player.velocity.y, 0, Player.FRICTION*Player.terrain_sm.friction_multiplier*delta)
		#print("applying friction")

func apply_air_resistance(delta):
	if Player.is_on_floor():
		return 
	if Player.movement_input.x==0:
		Player.velocity.y = move_toward(Player.velocity.y, 0, Player.AIR_RESISTANCE*Player.terrain_sm.friction_multiplier*delta)
		#print("applying air resistance")

func wall_jump():
	var wall_jump_velocity = Vector2.ZERO
	
	if Player.movement_input.x != 0:
		wall_jump_velocity.x = Player.WALL_JUMP_VELOCITY.y
		wall_jump_velocity.y = Player.WALL_JUMP_VELOCITY.x
	else:
		wall_jump_velocity.x = Player.WALL_JUMP_VELOCITY_NEUTRAL.y
		wall_jump_velocity.y = Player.WALL_JUMP_VELOCITY_NEUTRAL.x
	
	
	
	wall_jump_velocity.x *= 1
	wall_jump_velocity.y *= Player.wall_direction
	Player.velocity = wall_jump_velocity


func jump():
	Player.velocity.y += Player.jump_h_boost * Player.movement_input.x;
	Player.velocity.x = Player.max_jump_velocity
	Player.animated_sprite.scale = Vector2(Player.squish_x, Player.squish_y)

func variable_jump():
	if  (Input.is_action_just_released("Jump") or Input.is_action_just_released("JumpC")) and Player.velocity.x < Player.min_jump_velocity:
		Player.velocity.x = Player.min_jump_velocity

func slide_movement(delta):
	#Player.player_movement(delta)
	Player.velocity.x = Player.slide_down_speed

func climb_movement(delta):
	if Player.movement_input.y < 0:
		Player.slide_particles_left.emitting = false
		Player.slide_particles_right.emitting = false
		Player.velocity.x = Player.climb_up_speed
		Player.current_stamina -= Player.climb_stamina * delta
	elif Player.movement_input.y > 0:
		Player.velocity.x = Player.climb_down_speed
		
		if Player.is_on_floor():
			Player.slide_particles_left.emitting = false
			Player.slide_particles_right.emitting = false
		elif Player.wall_direction == -1 and Player.slide_particles_left.emitting == false:
			Player.slide_particles_left.emitting = true
		elif Player.wall_direction == 1 and Player.slide_particles_right.emitting == false:
			Player.slide_particles_right.emitting = true
			
	else:
		Player.slide_particles_left.emitting = false
		Player.slide_particles_right.emitting = false
		Player.velocity.x = 0
		Player.current_stamina -= Player.hold_stamina * delta

func climb_edge():
	Player.velocity.x = -120
	if Player.hazard_direction == 0:
		await get_tree().create_timer(0.05).timeout
		Player.velocity.y = -100 * Player.last_direction.x
	

func attempt_correction_up(amount: int):
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

func attempt_correction_right(amount: int):
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

func attempt_correction_left(amount: int):
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

func attempt_correction_down(amount: int):
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
	Player.velocity.x = -250
	Player.velocity.y = 0

func jump_pad():
	Player.velocity.x = -325
	Player.terrain_sm.instant_reset_movement_values()
	Player.current_stamina = Player.max_stamina
	Player.flashing_animation_player.stop()
	if !Player.can_dash:
		Player.can_dash = true
		Player.change_fuel_tank_state_full()

func velocity_y_less_than():
	if Player.velocity.x < 0:
		return true
	else:
		return false

func velocity_y_greater_than():
	if Player.velocity.x > 0:
		return true
	else:
		return false

func velocity_x_equals():
	if Player.velocity.y == 0:
		return true
	else:
		return false


func dash():
	if Player.movement_input != Vector2.ZERO:
		Player.dash_direction.x = Player.movement_input.y
		Player.dash_direction.y = -Player.movement_input.x
		
		Player.update_last_direction()
	else:
		Player.dash_direction.y = -Player.last_direction.x
	#Player.velocity = dash_direction.normalized() * dash_speed + Player.get_platform_velocity()
	Player.velocity = Player.dash_direction.normalized() * Player.dash_speed 

func end_dash():
	Player.velocity = Player.dash_direction.normalized() * Player.end_dash_speed
	Player.dash_direction = Vector2.ZERO

func grav_portal_boost():
	if Player.movement_input != Vector2.ZERO:
		var direction = Vector2.ZERO
		direction.x = Player.movement_input.y
		direction.y = -Player.movement_input.x
		
		Player.velocity = direction.normalized() * Player.grav_portal_boost
	else:
		Player.velocity.x += Player.grav_portal_boost
