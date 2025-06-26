extends Area2D

enum spawn_gravity_dir_enum {down = 0, up = 1, left = 2, right = 3}

@export var spawn_gravity_dir = spawn_gravity_dir_enum.down

func _on_body_entered(body):
	#animated_sprite_2d.play("Active")
	
	body.set_spawn(global_position, spawn_gravity_dir)
	
