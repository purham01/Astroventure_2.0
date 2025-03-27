extends "state.gd"

var dash_direction = Vector2.ZERO
var dashing = false
@export var dash_speed = 220
@export var end_dash_speed = 140
@export var dash_duration = 0.15
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown: Timer = $DashCooldown
@onready var dash_refill_cooldown: Timer = $DashRefillCooldown

func update(delta):
	if !dashing and Player.is_on_floor():
		return STATES.idle
	elif !dashing:
		return STATES.fall
		
func enter_state():
	Player.can_dash = false
	#Player.dash_buffer.stop()
	dashing = true
	Player.particle_manager.ghost_timer.start()
	dash_timer.start(dash_duration)
	#Player.shader_animation_player.play("dash_start") 
	
	FreezeFrameManager.freeze_frame(0.15)
	if Player.movement_input != Vector2.ZERO:
		dash_direction = Player.movement_input
	else:
		dash_direction = Player.last_direction
	Player.velocity = dash_direction.normalized() * dash_speed
	Player.player_camera.apply_shake(2)
	Input.start_joy_vibration(0, 1, 1, 0.2)
	Input.start_joy_vibration(0, 1, 0, 0.4)
	
func exit_state():
	Player.velocity = dash_direction.normalized() * end_dash_speed
	dashing = false
	Player.particle_manager.ghost_timer.stop()
	#Player.shader_animation_player.play("dash_stop")
	
	

func _on_timer_timeout() -> void:
	dashing = false
