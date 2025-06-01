extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _ready():
	if !ConfigFileHandler.show_tutorials:
		collision_shape_2d.disabled = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Ship":
		animation_player.play("show_popup")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Ship":
		animation_player.play("hide_popup")
