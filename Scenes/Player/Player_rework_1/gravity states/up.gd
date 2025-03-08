extends "gravity_state.gd"

func enter_state():
	Player.set_up_direction(Vector2.DOWN)
	Player.rotation_degrees=180
	if Player.prev_gs == GRAVITY_STATES.down:
		Player.position.y -= 16
	elif Player.prev_gs == GRAVITY_STATES.right or GRAVITY_STATES.left:
		Player.position.y -= 8
