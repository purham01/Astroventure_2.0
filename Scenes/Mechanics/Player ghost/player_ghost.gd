extends Node2D

@onready var visual: Sprite2D = $Visual

const _JITTER_LERP_SPEED = 0.2

func _process(delta: float) -> void:
	visual.global_transform = global_transform.interpolate_with(visual.global_transform, pow(0.5, delta * _JITTER_LERP_SPEED))

func _physics_process(delta: float) -> void:
	pass
