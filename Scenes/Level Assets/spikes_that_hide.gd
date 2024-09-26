extends Node2D

@export var retracted = false
@onready var animation_player = $AnimationPlayer

func set_collision(value):
	$HazardArea.set_collision_layer_value(3, value)
	retracted = !retracted
