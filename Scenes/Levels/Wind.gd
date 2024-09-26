extends GPUParticles2D

@export var player : CharacterBody2D
@export var windspeed : float
@export var average_time : float

var timer = 0
var active = false
var rng = RandomNumberGenerator.new()

@onready var mat : ParticleProcessMaterial = get_process_material()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		timer += delta
		if timer >= average_time + rng.randf_range(-4.0, 4.0):
			timer = 0
			windspeed *= -1
			mat.direction.x *= -1
		if not player.is_on_floor():
			player.velocity.x += windspeed


func _on_wind_body_entered(body):
	emitting = true
	active = true


func _on_wind_body_exited(body):
	emitting = false
	active = false
	timer = 0
