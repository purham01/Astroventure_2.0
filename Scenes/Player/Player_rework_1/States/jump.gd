extends "state.gd"

func update(delta):
	Player.current_gs.gravity(delta)
	Player.player_movement(delta)
	
	#Variable jump
	Player.current_gs.variable_jump()
	
	if Player.wall_direction != 0 and Player.climb_input and Player.prev_state != STATES.climb:
		return STATES.climb
		
	if Player.wall_direction != 0 and Player.jump_input_actuation and !Player.climb_input:
		return STATES.wall_jump
		
	if Player.velocity.y > 0:
		return STATES.fall
		
	if Player.dash_input and Player.can_dash:
		return STATES.dash
		
	return null

func enter_state():
	Player.current_gs.jump()
	
