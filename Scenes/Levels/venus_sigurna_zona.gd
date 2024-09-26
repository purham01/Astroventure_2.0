extends Area2D

@export var timer : ProgressBar

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print_debug("PLAYER ENTERED")
		timer.enabled = false

func _on_body_exited(body):
	if body.is_in_group("Player"):
		print_debug("PLAYER EXITED")
		timer.enabled = true
