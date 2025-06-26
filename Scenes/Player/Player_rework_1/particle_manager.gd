extends Node2D

@export var ghost_node : PackedScene
@onready var dash_ghost_timer: Timer = $DashGhostTimer

@export var animated_sprite : AnimatedSprite2D = null
var particles_emitting = false

func add_dash_ghost():
	var ghost = ghost_node.instantiate()
	ghost.global_transform = animated_sprite.global_transform
	ghost.offset.y = -10
	ghost.flip_h = animated_sprite.flip_h
	ghost.frame = animated_sprite.frame
	get_tree().current_scene.add_child(ghost)


func _on_ghost_timer_timeout() -> void:
	add_dash_ghost()
