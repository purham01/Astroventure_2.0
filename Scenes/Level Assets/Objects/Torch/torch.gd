extends Node2D
@onready var point_light_2d: PointLight2D = $PointLight2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		point_light_2d.enabled = true
