extends "state.gd"


func update(delta):
	play_walking_sfx()
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
	if !Player.can_dash:
		Player.can_dash = true
		Player.change_fuel_tank_state_full()
	Player.animated_sprite.play("run")

func play_walking_sfx():
	if Player.animated_sprite.animation == "run":
		if Player.animated_sprite.frame == 0 or Player.animated_sprite.frame == 6:
				FmodBanks.walk.set_parameter("Parameter 1", randf())
				FmodBanks.walk.play()
