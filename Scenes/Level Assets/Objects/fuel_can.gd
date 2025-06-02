extends "object.gd"

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var reset_timer: Timer = $ResetTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

func _ready():
	Events.connect("change_gravity", change_gravity)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if !body.can_dash:
			body.can_dash = true
			body.change_fuel_tank_state_full()
		body.current_stamina = body.max_stamina
		body.flashing_animation_player.stop()
		collision_shape_2d.set_deferred("disabled", true)
		sprite_2d.visible = false
		#FreezeFrameManager.freeze_frame(0.05)
		FmodBanks.portal_enter.play()
		reset_timer.start()


func _on_reset_timer_timeout() -> void:
	collision_shape_2d.set_deferred("disabled", false)
	animation_player_2.play("come_back")

func change_gravity(new_rotation_degrees):
	var tween = get_tree().create_tween()
	#print( abs(rotation_degrees - new_rotation_degrees))
	#print("New rotation: ",new_rotation_degrees)
	if new_rotation_degrees == 0 and rotation_degrees == 270:
		new_rotation_degrees = 360
	elif abs(rotation_degrees - new_rotation_degrees) > 180:
		new_rotation_degrees = new_rotation_degrees - 360
	#print("Current rotation: ", rotation_degrees)
	#print("New rotation: ",new_rotation_degrees)
	
	tween.tween_property(self, "rotation_degrees", new_rotation_degrees, CameraShake.camera_transition_duration)
	await tween.finished
	if rotation_degrees == -360 or rotation_degrees == 360:
		rotation_degrees = 0
