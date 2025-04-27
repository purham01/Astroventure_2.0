extends Node2D

@export var destruction_direction = Vector2.RIGHT

var knockback_amount = Vector2(100, 200)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.current_state == body.STATES.dash:
		#if destruction_direction.x == body.velocity.normalized().x:
		print(knockback_amount * global_position.direction_to(body.global_position))
		body.change_state(body.STATES.move)
		body.velocity = Vector2.ZERO
		body.velocity = knockback_amount * global_position.direction_to(body.global_position)
		queue_free()
		
