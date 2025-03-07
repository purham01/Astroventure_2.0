extends "state.gd"

func update(delta):
	Player.gravity(delta)
	player_movement()
	
	#Variable jump
	if Input.is_action_just_released("Jump") and Player.velocity.y < Player.min_jump_velocity:
		Player.velocity.y = Player.min_jump_velocity

	if Player.velocity.y > 0:
		return STATES.fall
	if Player.dash_input and Player.can_dash:
		return STATES.dash
	return null

func enter_state():
	Player.velocity.y = Player.max_jump_velocity
