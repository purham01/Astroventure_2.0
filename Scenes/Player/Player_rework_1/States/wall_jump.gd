extends "state.gd"

func update(delta):
	Player.current_gs.gravity(delta)
	#Player.player_movement(delta)
	
	if Player.wall_direction != 0 and !Player.jump_buffer.is_stopped():
		return STATES.wall_jump
	
	if Player.wall_direction != 0 and Player.jump_input_actuation:
		return STATES.wall_jump
	
	if Player.wall_direction != 0 and Player.climb_input and Player.wall_slide_cooldown.is_stopped() and Player.is_on_wall():
		return STATES.climb
		
	if Player.current_gs.velocity_y_greater_than:
		return STATES.fall
		
	if Player.dash_input and Player.can_dash:
		return STATES.dash
		
	return null

func enter_state():
	Player.terrain_sm.instant_reset_movement_values()
	Player.current_gs.wall_jump()
	Player.wall_slide_cooldown.start()

func exit_state():
	Player.jump_buffer.stop()

func handle_jump_buffer():
	if Player.wall_direction == 0 and Player.jump_input_actuation:
		Player.jump_buffer.start()
