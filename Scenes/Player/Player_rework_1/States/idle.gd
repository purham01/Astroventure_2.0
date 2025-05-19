extends "state.gd"

func update(delta):
	Player.current_gs.gravity(delta)
	Player.player_movement(delta)
	
	if Player.movement_input.x != 0:
		return STATES.move
	
	if Player.jump_input_actuation == true:
		return STATES.jump
	
	if Player.current_gs.velocity_y_greater_than():
		return STATES.fall
	
	if Player.dash_input and Player.can_dash:
		return STATES.dash
	
	if sign(Player.last_direction.x) == sign(Player.wall_direction) and Player.climb_input and (Player.is_on_wall() or Player.wall_direction != 0):
		return STATES.climb
	
	return null

func enter_state():
	if !Player.can_dash:
		Player.can_dash = true
		Player.change_fuel_tank_state_full()
	Player.animated_sprite.play("idle")
