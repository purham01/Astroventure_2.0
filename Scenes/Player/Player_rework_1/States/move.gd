extends "state.gd"

func update(delta):
	Player.current_gs.gravity(delta)
	Player.player_movement(delta)
	
	if Player.dash_input and Player.can_dash:
		return STATES.dash
	
	if Player.current_gs.velocity_x_equals():
		return STATES.idle
		
	if Player.current_gs.velocity_y_greater_than():
		return STATES.fall
		
	if Player.jump_input_actuation:
		return STATES.jump

	if Player.wall_direction != 0 and Player.climb_input and Player.is_on_wall():
		return STATES.climb
		
	return null


func enter_state():
	Player.can_dash = true
