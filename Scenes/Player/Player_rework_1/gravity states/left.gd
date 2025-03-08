extends "gravity_state.gd"

func enter_state():
	Player.rotation_degrees = 90
	Player.set_up_direction(Vector2.RIGHT)
	if Player.prev_gs == GRAVITY_STATES.right:
		Player.position.x-=16
