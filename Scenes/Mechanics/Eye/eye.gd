extends StaticBody2D

@onready var eye_sprite: AnimatedSprite2D = $EyeSprite
@onready var poof: AnimatedSprite2D = $Poof

@export var level_codename = ""
var knockback_amount = Vector2(200, 200)
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	Events.connect("change_gravity", change_gravity)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.name == "Player":
		if body.current_state == body.STATES.dash:
			print(knockback_amount * global_position.direction_to(body.global_position))
			body.change_state(body.STATES.move)
			body.velocity = Vector2.ZERO
			body.velocity = knockback_amount * global_position.direction_to(body.global_position)
			eye_sprite.hide()
			poof.show()
			poof.play("default")
			emit_collected_signal()
		else:
			animation_player.play("bounce")
			body.change_state(body.STATES.move)
			body.velocity = Vector2.ZERO
			body.velocity = knockback_amount * global_position.direction_to(body.global_position)


func _on_poof_animation_finished() -> void:
	pass

func emit_collected_signal():
	pass

func save_eye_data(key):
	var dict : Dictionary = Save.save_data.get(level_codename)
	dict.set(key, true)
	Save.save_data.set(level_codename, dict)
	Save.save_game()
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "bounce":
		animation_player.play

func change_gravity(new_rotation_degrees):
	var tween = get_tree().create_tween()
	
	if new_rotation_degrees == 0 and rotation_degrees == 270:
		new_rotation_degrees = 360
	elif abs(rotation_degrees - new_rotation_degrees) > 180:
		new_rotation_degrees = new_rotation_degrees - 360

	
	tween.tween_property(self, "rotation_degrees", new_rotation_degrees, CameraShake.camera_transition_duration)
	await tween.finished
	if rotation_degrees == -360 or rotation_degrees == 360:
		rotation_degrees = 0
