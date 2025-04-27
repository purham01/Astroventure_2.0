extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.current_gs.jump_pad()
		animation_player.play("squish")
