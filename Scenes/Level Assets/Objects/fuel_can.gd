extends "object.gd"

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var reset_timer: Timer = $ResetTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if !body.can_dash:
			body.can_dash = true
			body.change_fuel_tank_state_full()
		body.current_stamina = body.max_stamina
		body.flashing_animation_player.stop()
		collision_shape_2d.set_deferred("disabled", true)
		sprite_2d.visible = false
		reset_timer.start()


func _on_reset_timer_timeout() -> void:
	collision_shape_2d.set_deferred("disabled", false)
	animation_player_2.play("come_back")
