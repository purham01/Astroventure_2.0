extends "state.gd"

@export var transition_duration = 0.5
@onready var transition_timer: Timer = $TransitionTimer

func update(delta):
	Player.current_gs.gravity(delta)
	if !Player.inTransition or Player.is_on_floor():
		return STATES.idle

func enter_state():
	Player.inTransition = true
	transition_timer.start(transition_duration)
	
	


func _on_transition_timer_timeout() -> void:
	Player.inTransition = false
