extends "state.gd"

func update(delta):
	Player.current_gs.climb_movement(delta)
	
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
		
	if Player.wall_direction == 0:
		Player.current_gs.climb_edge()
		return STATES.fall
		
	if !Player.climb_input:
		if Player.movement_input.x == Player.wall_direction and Player.wall_direction != 0 and Player.wall_slide_cooldown.is_stopped():
			return STATES.wall_slide
			
		if Player.wall_direction == 0 or Player.movement_input.x != Player.wall_direction:
			return STATES.fall
	return null
