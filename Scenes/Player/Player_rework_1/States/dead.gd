extends "state.gd"

@onready var respawn_transition_1: AnimatedSprite2D = %RespawnTransition1
@onready var respawn_transition_2: AnimatedSprite2D = %RespawnTransition2
@onready var respawn_delay: Timer = $RespawnDelay
func update(delta):
	if !Player.playerDead:
		return STATES.idle

func enter_state():
	print("Respawning player")
	FmodBanks.die.set_parameter("Parameter 1", randf())
	FmodBanks.die.play()
	Player.playerDead = true
	Player.hazard_detector_collision_shape.set_deferred("disabled", true)
	Player.follower_controller.star_counter = 0
	
	Player.player_camera.apply_shake(2)
	Input.start_joy_vibration(0, 0, 1, 0.2)
	
	Player.current_stamina = Player.max_stamina
	Player.flashing_animation_player.stop()
	Player.velocity = Vector2.ZERO
	
	#Player.fuel_tank.hide()
	Player.animated_sprite.play("poof") #sometimes this just doesn't play, dunno why
	Player.animated_sprite.position.y += 1

	await(Player.animated_sprite.animation_finished)
	Player.animated_sprite.hide()
	
	respawn_transition_1.show()
	respawn_transition_1.play("default")
	
	FmodBanks.respawn.play()
	await respawn_transition_1.animation_finished
	FmodBanks.respawn_2.play()
	Events.player_dead.emit()
	respawn_delay.start()
	Events.enter_portal.emit()
	
	
	reset_spawn_gravity()
	Player.global_position = Player.starting_position
	
	Player.animated_sprite.position.y-=1
	Player.hazard_detector_collision_shape.set_deferred("disabled", false)
	Player.has_first_moved_after_respawn = false
	Player.animated_sprite.show()
	Player.animated_sprite.play("idle")
	
	await respawn_delay.timeout
	respawn_transition_2.show()
	respawn_transition_2.play("default")
	respawn_transition_1.hide()
	
	await respawn_transition_2.animation_finished
	Player.playerDead = false
	Player.velocity = Vector2.ZERO
	

func reset_spawn_gravity():
	if Player.starting_gravity == Player.current_gs:
		return
	else:
		Player.change_gravity_state(Player.starting_gravity)
		Events.emit_signal("enter_portal")
