extends "eye.gd"

func _on_poof_animation_finished() -> void:
	save_eye_data("LeftEyeCollected")
	queue_free()

func emit_collected_signal():
	Events.collected_left_eye.emit()
