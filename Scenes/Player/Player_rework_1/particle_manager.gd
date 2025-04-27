extends Node

@export var ghost_node : PackedScene
@onready var dash_ghost_timer: Timer = $DashGhostTimer

var Player : CharacterBody2D = null
var particles_emitting = false

func add_dash_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(Vector2(Player.position.x, Player.position.y - 8), Player.animated_sprite.scale)
	ghost.flip_h = Player.animated_sprite.flip_h
	get_tree().current_scene.add_child(ghost)


func _on_ghost_timer_timeout() -> void:
	add_dash_ghost()
