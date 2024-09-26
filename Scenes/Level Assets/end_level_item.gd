extends Area2D

func _on_body_entered(body):
	Events.level_completed.emit()
