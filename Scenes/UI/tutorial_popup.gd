extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		animation_player.play("show_popup")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		animation_player.play("hide_popup")
