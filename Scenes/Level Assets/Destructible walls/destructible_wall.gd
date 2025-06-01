extends Node2D

@export var destruction_direction = Vector2.RIGHT
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D

var knockback_amount = Vector2(200, 200)

func _physics_process(delta: float) -> void:
	var bodies = area_2d.get_overlapping_bodies()
	for b in bodies:
		_on_area_2d_body_entered(b)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.current_state == body.STATES.dash:
		#if destruction_direction.x == body.velocity.normalized().x:
		print(knockback_amount * collision_shape_2d.global_position.direction_to(body.global_position))
		body.change_state(body.STATES.special_jump)
		body.velocity = Vector2.ZERO
		var knockback_direction = collision_shape_2d.global_position.direction_to(body.global_position)
		knockback_direction
		body.velocity = knockback_amount * knockback_direction 
		queue_free()
