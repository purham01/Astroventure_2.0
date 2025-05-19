extends "state.gd"

@export var transition_duration = 1.10
@onready var transition_timer: Timer = $TransitionTimer

func update(delta):
	if !Player.inTransition:
		return STATES.fall

func enter_state():
	Player.animated_sprite.play("jump")
	Player.inTransition = true
	Player.velocity = Vector2.ZERO
	Player.gravity_rotation_animation_player.play("grav_change")
	
	if !Player.can_dash:
		Player.can_dash = true
		Player.change_fuel_tank_state_full()
	Player.current_stamina = Player.max_stamina
	Player.flashing_animation_player.stop()
	transition_timer.start(transition_duration)


func exit_state():
	Events.emit_signal("exit_portal")
	Player.gravity_rotation_animation_player.play("grav_change_2")
	
	Player.current_gs.grav_portal_boost()
	Player.player_camera.apply_shake(2 * ConfigFileHandler.camera_shake) 
	


func _on_transition_timer_timeout() -> void:
	Player.inTransition = false


func _on_gravity_rotation_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "grav_change":
		Events.emit_signal("enter_portal")
	#if anim_name == "grav_change_2":
	#	Events.emit_signal("exit_portal")
