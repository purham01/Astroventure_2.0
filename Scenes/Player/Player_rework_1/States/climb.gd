extends "state.gd"

var was_looking_back = false

func update(delta):
	play_walking_sfx()
	change_animation()
	Player.current_gs.climb_movement(delta)
	
	if Player.dash_input and Player.can_dash:
		return STATES.dash
	
	#stamina check
	if Player.current_stamina <= 0:
		if sign(Player.movement_input.x) == -sign(Player.wall_direction):
			return STATES.fall
		else:
			return STATES.wall_slide
	
	if sign(Player.movement_input.x) == -sign(Player.wall_direction) and Player.jump_input_actuation:
		return STATES.wall_jump
		
	elif Player.jump_input_actuation and Player.current_stamina > 0:
		Player.current_stamina -= Player.jump_stamina
		return STATES.jump
		
	if (!Player.is_on_wall() and Player.wall_direction == 0)and Player.current_gs.velocity_y_less_than():
		Player.current_gs.climb_edge()
		return STATES.fall
	elif !Player.is_on_wall() and Player.wall_direction == 0:
		return STATES.fall
		
	if !Player.climb_input:
		if Player.movement_input.x == Player.wall_direction and Player.wall_direction != 0 and Player.wall_slide_cooldown.is_stopped():
			return STATES.wall_slide
			
		if (!Player.is_on_wall() and Player.wall_direction == 0) or Player.movement_input.x != Player.wall_direction:
			return STATES.fall
	return null

func play_walking_sfx():
	if Player.animated_sprite.animation == "climb":
		if Player.animated_sprite.frame == 2:
				FmodBanks.walk.set_parameter("Parameter 1", randf())
				FmodBanks.walk.play()

func enter_state():
	FmodBanks.walk.set_parameter("Parameter 1", randf())
	FmodBanks.walk.play()
	print(Player.last_direction)
	print(Player.wall_direction)
	Player.terrain_sm.instant_reset_movement_values()

func exit_state():
	was_looking_back = false
	Player.slide_particles_left.emitting = false
	Player.slide_particles_right.emitting = false

func change_animation():
	if Player.movement_input.y < 0:
		#going up
		Player.animated_sprite.play("climb")
		was_looking_back = false
	else:
		if !was_looking_back and Player.movement_input.x == -Player.wall_direction:
			was_looking_back = true
			Player.animated_sprite.play("climb_look_back")
		elif was_looking_back:
			if Player.movement_input.x != -Player.wall_direction:
				#var temp_frame = Player.animated_sprite.frame
				Player.animated_sprite.play_backwards("climb_look_back")
				#Player.animated_sprite.frame = temp_frame
				await Player.animated_sprite.animation_finished
				was_looking_back = false
		else:
			Player.animated_sprite.play("wallslide")
