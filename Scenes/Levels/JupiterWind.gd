extends GPUParticles2D

@export var player : CharacterBody2D
@export var windspeed : float
@export var average_time : float

var timer = 0
var active = false

@onready var mat : ParticleProcessMaterial = get_process_material()

func _process(delta):
	if active:
		if not player.is_on_floor():
			player.velocity.x -= windspeed

func _on_jupiter_wind_body_entered(body):
	emitting = true
	active = true


func _on_jupiter_wind_body_exited(body):
	emitting = false
	active = false

