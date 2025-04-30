extends "state.gd"

func update(delta):
	Player.current_gs.gravity(delta)
	Player.player_movement(delta)
	
	#Variable jump
	Player.current_gs.variable_jump()
	
	if Player.dash_input and Player.can_dash:
		return STATES.dash
	
	if Player.wall_direction != 0 and Player.climb_input and Player.prev_state != STATES.climb and (Player.is_on_wall() or Player.wall_direction != 0):
		return STATES.climb
		
	if Player.wall_direction != 0 and Player.jump_input_actuation and !Player.climb_input:
		return STATES.wall_jump
		
	if Player.current_gs.velocity_y_greater_than():
		return STATES.fall
		
	return null

func enter_state():
	Player.current_gs.jump()
	
