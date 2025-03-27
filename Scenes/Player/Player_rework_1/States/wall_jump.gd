extends "state.gd"

func update(delta):
	Player.current_gs.gravity(delta)
	#Player.player_movement(delta)
	
	if Player.wall_direction != 0 and !Player.jump_buffer.is_stopped():
		return STATES.wall_jump
	
	if Player.wall_direction != 0 and Player.jump_input_actuation:
		return STATES.wall_jump
	
	if Player.wall_direction != 0 and Player.climb_input and Player.wall_slide_cooldown.is_stopped():
		return STATES.climb
		
	if Player.velocity.y > 0:
		return STATES.fall
		
	if Player.dash_input and Player.can_dash:
		return STATES.dash
		
	return null

func enter_state():
	Player.current_gs.wall_jump()
	Player.wall_slide_cooldown.start()

func handle_jump_buffer():
	if Player.wall_direction == 0 and Player.jump_input_actuation:
		Player.jump_buffer.start()
