extends Area2D

@onready var start_position = global_position
@onready var direction_marker: Marker2D = $DirectionMarker
@onready var cooldown: Timer = $Cooldown
@onready var start_delay: Timer = $StartDelay
@onready var fireball: AnimatedSprite2D = $Fireball
@onready var explosion: AnimatedSprite2D = $Explosion
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var speed = 20
@export var disabled = false
@export var start_delay_enable = false
@export var cooldown_time = 1.0
@export var start_delay_time = 0.0

enum impact {down = 0, left = 1, right = 2}

@export var impact_dir = impact.down

func _ready() -> void:
	
	if start_delay_enable:
		disabled = true
		start_delay.start(start_delay_time)

	match impact_dir:
		0:
			explosion.rotation_degrees = 90
		1:
			explosion.rotation_degrees = 180
		2:
			explosion.rotation_degrees = 0

func _physics_process(delta):
	if !disabled:
		global_position += start_position.direction_to(direction_marker.global_position) * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ground":
		explosion.global_position = global_position
		#explosion.rotation = -rotation + start_position.direction_to(direction_marker.global_position).angle_to(start_position.direction_to(body.global_position))

		disabled = true
		collision_shape_2d.set_deferred("disabled", true)
		fireball.hide()
		explosion.show()
		explosion.play("default")
		#FmodBanks.impact.play()
		
		await explosion.animation_finished
		cooldown.start(cooldown_time)
		explosion.hide()
		global_position = start_position
	


func _on_cooldown_timeout() -> void:
	fireball.show()
	collision_shape_2d.set_deferred("disabled", false)
	disabled = false
	#FmodBanks.shoot.play()


func _on_start_delay_timeout() -> void:
	disabled = false
