extends "state.gd"

@export var climb_speed = Globals.UNIT_SIZE * 6
@export var slide_friction = 0.7

func update(delta):
	slide_movement(delta)
	if Player.get_next_to_wall() == null:
		return STATES.fall
	if Player.jump_input_actuation: 
		return STATES.jump
	if Player.is_on_floor():
		return STATES.idle
	return null

func slide_movement(delta):
	if Player.climb_input:
		if Player.movement_input.y < 0:
			Player.velocity.y = -climb_speed
		elif Player.movement_input.y > 0:
			Player.velocity.y = climb_speed
		else:
			Player.velocity.y = 0
	else:
		player_movement()
		Player.gravity(delta)
		Player.velocity.y *= slide_friction
