extends Area2D

var movement_vector := Vector2(-1, 0)

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size := AsteroidSize.LARGE
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

@onready var start_position = global_position

var speed := 20

func _ready():
	rotation = randf_range(4*PI/3, 5*PI/3)
	
	match  size:
		AsteroidSize.LARGE:
			speed = randf_range(20, 30)
			animated_sprite_2d.play("bigMeteor")
			collision_shape_2d.shape = preload("res://Resources/asteroid_cshape_big.tres")
		AsteroidSize.MEDIUM:
			speed = randf_range(40, 50)
			animated_sprite_2d.play("mediumMeteor")
			collision_shape_2d.shape = preload("res://Resources/asteroid_cshape_med.tres")
		AsteroidSize.SMALL:
			speed = randf_range(60, 70)
			animated_sprite_2d.play("smallMeteor")
			collision_shape_2d.shape = preload("res://Resources/asteroid_cshape_small.tres")

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var screen_size = get_viewport_rect().size

func _on_body_entered(body):
	if body.is_in_group("MercurySurface"):
		global_position = start_position
		
	
