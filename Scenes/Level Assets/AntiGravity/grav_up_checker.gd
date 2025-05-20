extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.change_gravity_state(body.GRAVITY_STATES.up)
		animation_player.play("enter_portal")
		await Events.enter_portal
		body.global_position = global_position
		
		
		await Events.exit_portal
		animation_player.play("exit_portal")
