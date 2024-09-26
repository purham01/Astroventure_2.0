extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D

func _on_body_entered(body):
	animated_sprite_2d.play("Active")
	body.set_spawn(global_position)
