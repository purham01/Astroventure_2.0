extends Node2D

@onready var path = $PathFollow2D
@export var speed = 100

var reverse = false
var time_to_turn = 0.5

func _process(delta):
	if not reverse:
		path.set_progress(path.get_progress() + speed * delta)
		if path.progress_ratio == 1:
			await get_tree().create_timer(time_to_turn).timeout
			reverse = true
	else:
		path.set_progress(path.get_progress() - speed * delta)
		if path.progress_ratio == 0:
			await get_tree().create_timer(time_to_turn).timeout
			reverse = false
		
