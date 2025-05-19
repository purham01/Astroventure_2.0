extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.change_gravity_state(body.GRAVITY_STATES.down)
		animation_player.play("enter_portal")
		await Events.enter_portal
		body.global_position = global_position
		Events.emit_signal("change_gravity", 0)
		
		await Events.exit_portal
		animation_player.play("exit_portal")
