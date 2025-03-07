extends "state.gd"

var dash_direction = Vector2.ZERO
var dash_speed = 200.0
var dashing = false
@export var dash_duration = 0.2
@onready var dash_timer: Timer = $DashTimer


func update(delta):
	if !dashing:
		return STATES.fall
		
func enter_state():
	Player.can_dash = false
	dashing = true
	dash_timer.start(dash_duration)
	if Player.movement_input != Vector2.ZERO:
		dash_direction = Player.movement_input
	else:
		dash_direction = Player.last_direction
	Player.velocity = dash_direction.normalized() * dash_speed
	
func exit_state():
	dashing = false


func _on_timer_timeout() -> void:
	dashing = false
