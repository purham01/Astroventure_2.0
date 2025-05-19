extends "state.gd"

@export var transition_duration = 0.5
@onready var transition_timer: Timer = $TransitionTimer

func update(delta):
	Player.current_gs.gravity(delta)
	Player.player_movement(delta)
	if !Player.inTransition or Player.is_on_floor():
		return STATES.idle

func enter_state():
	Player.inTransition = true
	if !Player.can_dash:
		Player.can_dash = true
		Player.change_fuel_tank_state_full()
	Player.current_stamina = Player.max_stamina
	Player.flashing_animation_player.stop()
	transition_timer.start(transition_duration)
	
	


func _on_transition_timer_timeout() -> void:
	Player.inTransition = false
