extends "state.gd"




func update(delta):
	Player.current_gs.slide_movement(delta)
	
	if Player.dash_input and Player.can_dash:
		return STATES.dash
	
	if sign(Player.last_direction.x) == sign(Player.wall_direction) and Player.climb_input and Player.current_stamina > 0 and (Player.is_on_wall() or Player.wall_direction != 0):
		return STATES.climb
		
	#first part, fall off wall when not holding towards wall, second part, dont fall off wall when holding climb and dont have stamina
	if (Player.wall_direction == 0 or sign(Player.movement_input.x) != sign(Player.wall_direction)) and !(Player.climb_input and Player.current_stamina <= 0 and sign(Player.movement_input.x) != -sign(Player.wall_direction) and Player.wall_direction != 0):
		return STATES.fall

	if Player.jump_input_actuation: 
		return STATES.wall_jump
		
	if Player.is_on_floor():
		return STATES.idle
	
	return null

func enter_state():
	if Player.wall_direction == -1:
		Player.slide_particles_left.emitting = true
	elif Player.wall_direction == 1:
		Player.slide_particles_right.emitting = true
	Player.animated_sprite.play("wallslide")

	Player.terrain_sm.instant_reset_movement_values()

func exit_state():
	Player.wall_slide_cooldown.start()
	Player.slide_particles_left.emitting = false
	Player.slide_particles_right.emitting = false
