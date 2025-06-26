extends Node2D
@onready var torch_light: PointLight2D = $TorchLight

@export var torch_transition_duration = 0.5

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and torch_light.enabled == false:
		torch_light.energy = 0.0
		torch_light.enabled = true
		
		FmodBanks.dash.set_parameter("Parameter 1", 0.5)
		FmodBanks.dash.play()
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_SPRING)
		
		tween.tween_property(torch_light,"energy",1.0,torch_transition_duration)
		
		await tween.finished
		
		flicker()

func flicker():
	torch_light.energy = randf() * 0.1 + 0.9
	torch_light.scale = Vector2(1, 1) * torch_light.energy
	await get_tree().create_timer(0.133333).timeout
	flicker()
