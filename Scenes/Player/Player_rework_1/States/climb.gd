extends "state.gd"

func update(delta):
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

func enter_state():
	Player.terrain_sm.instant_reset_movement_values()
