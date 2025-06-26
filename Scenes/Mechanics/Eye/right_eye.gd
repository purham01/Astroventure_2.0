extends "eye.gd"

func _on_poof_animation_finished() -> void:
	save_eye_data("RightEyeCollected")
	queue_free()
	
func emit_collected_signal():
	Events.collected_right_eye.emit()
