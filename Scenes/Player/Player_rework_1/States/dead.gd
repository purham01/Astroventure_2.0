extends "state.gd"

func update(delta):
	if !Player.playerDead:
		return STATES.idle

func enter_state():
	print("Respawning player")
	Player.playerDead = true
	Player.collision_shape_2d.set_deferred("disabled", true)
	Player.follower_controller.star_counter = 0
	Events.player_dead.emit()
	
	
	Player.player_camera.apply_shake(2)
	Input.start_joy_vibration(0, 0, 1, 0.2)
	
	Player.current_stamina = Player.max_stamina
	Player.flashing_animation_player.stop()
	Player.velocity = Vector2.ZERO
	Player.animated_sprite.play("poof") #sometimes this just doesn't play, dunno why
	Player.animated_sprite.position.y += 1
	await(Player.animated_sprite.animation_finished)
	Player.global_position = Player.starting_position
	Player.animated_sprite.play("respawn")
	await(Player.animated_sprite.animation_finished)
	
	Player.animated_sprite.position.y-=1
	Player.collision_shape_2d.set_deferred("disabled", false)
	Player.playerDead = false
	Player.animated_sprite.play("idle")
