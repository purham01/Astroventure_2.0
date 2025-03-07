extends "state.gd"

@onready var coyote_time: Timer = $CoyoteTime
@export var coyote_duration = 0.2
var can_jump = true

func update(delta):
	Player.gravity(delta)
	player_movement()
	if Player.is_on_floor():
		return STATES.idle
	if Player.dash_input and Player.can_dash:
		return STATES.dash
	if Player.get_next_to_wall() != null:
		return STATES.slide
	if Player.jump_input_actuation and can_jump:
		return STATES.jump
	return null

func enter_state():
	if Player.prev_state == STATES.idle or Player.prev_state == STATES.move or Player.prev_state == STATES.slide:
		can_jump = true
		coyote_time.start(coyote_duration)
	else:
		can_jump = false


func _on_coyote_time_timeout() -> void:
	can_jump = false
