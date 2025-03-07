extends "state.gd"

func update(delta):
	Player.gravity(delta)
	if Player.movement_input.x != 0:
		return STATES.move
	
	if Player.jump_input_actuation == true:
		return STATES.jump
	
	if Player.velocity.y > 0:
		return STATES.fall
	
	if Player.dash_input and Player.can_dash:
		return STATES.dash
	
	return null

func enter_state():
	Player.can_dash = true
