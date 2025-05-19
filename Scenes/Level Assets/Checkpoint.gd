extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D
var spawn_gravity_dir = ""

func _on_body_entered(body):
	#animated_sprite_2d.play("Active")
	
	body.set_spawn(global_position, spawn_gravity_dir)
	
