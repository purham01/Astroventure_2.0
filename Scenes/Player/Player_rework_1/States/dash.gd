extends "state.gd"


var dashing = false
@export var dash_duration = 0.15
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown: Timer = $DashCooldown
@onready var dash_refill_cooldown: Timer = $DashRefillCooldown
@onready var reset_on_platform_leave: Timer = $ResetOnPlatformLeave


func update(delta):
	#Player.apply_floor_snap()
	#if !dashing and Player.is_on_floor():
		#return STATES.idle
	if !dashing:
		return STATES.fall
		
func enter_state():
	Player.animated_sprite.play("dash")
	
	Player.is_dashing = true
	Player.platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_DO_NOTHING
	Player.can_dash = false
	#Player.dash_buffer.stop()
	dashing = true
	Player.particle_manager.dash_ghost_timer.start()
	Player.dash_particles.emitting = true
	dash_timer.start(dash_duration)

	#Player.shader_animation_player.play("dash_start") 
	
	FreezeFrameManager.freeze_frame(0.05)
	Player.current_gs.dash()
	
	
	Player.change_fuel_tank_state_empty()
	Player.player_camera.apply_shake(1 * ConfigFileHandler.camera_shake) 
	if ConfigFileHandler.input_type:
		Input.start_joy_vibration(0, 1 * ConfigFileHandler.controller_vibration, 1 * ConfigFileHandler.controller_vibration, 0.2)
		Input.start_joy_vibration(0, 1 * ConfigFileHandler.controller_vibration, 0, 0.4)
	
func exit_state():
	Player.animated_sprite.play("fall")

	Player.current_gs.end_dash()
	#Player.velocity -= (dash_direction + Player.get_platform_velocity().normalized()).normalized() * (dash_speed - end_dash_speed) 
	dashing = false
	Player.is_dashing = false
	Player.dash_particles.emitting = false
	Player.particle_manager.dash_ghost_timer.stop()
	
	if Player.terrain_sm.current_terrain_type == 1 or Player.terrain_sm.current_terrain_type == -1:
		Player.terrain_sm.instant_reset_movement_values()
	#Player.shader_animation_player.play("dash_stop")
	#Player.platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_ADD_VELOCITY
	reset_on_platform_leave.start()


func _on_timer_timeout() -> void:
	dashing = false


func _on_reset_on_platform_leave_timeout() -> void:
	Player.platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_ADD_VELOCITY
