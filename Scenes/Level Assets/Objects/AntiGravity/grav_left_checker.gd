extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.change_gravity_state(body.GRAVITY_STATES.left)
		animation_player.play("enter_portal")
		FmodBanks.portal_enter.play()
		await Events.enter_portal
		body.global_position = global_position
		
		FmodBanks.portal_exit.play()
		await Events.exit_portal
		FmodBanks.portal_enter.play()
		animation_player.play("exit_portal")
