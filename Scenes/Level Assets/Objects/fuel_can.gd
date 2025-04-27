extends "object.gd"

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var reset_timer: Timer = $ResetTimer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.can_dash = true
		body.current_stamina = body.max_stamina
		collision_shape_2d.set_deferred("disabled", true)
		sprite_2d.visible = false
		reset_timer.start()


func _on_reset_timer_timeout() -> void:
	collision_shape_2d.set_deferred("disabled", false)
	sprite_2d.visible = true
