extends Area2D

var player : CharacterBody2D = null
@export var windspeed : float
@export var uptime : float
@export var downtime : float
@export var wind_direction : Vector2
#@export var wind_particles : GPUParticles2D

@onready var wind_particles_uptime: GPUParticles2D = $CanvasLayer/WindParticlesUptime
@onready var wind_particles_downtime: GPUParticles2D = $CanvasLayer/WindParticlesDowntime
@onready var uptime_timer: Timer = $UptimeTimer
@onready var downtime_timer: Timer = $DowntimeTimer

@export_category("Particles")
@export var min_speed_uptime = 50.0
@export var max_speed_uptime = 200.0
@export var min_speed_downtime = 10.0
@export var max_speed_downtime = 20.0
@export var uptime_amount = 100
@export var downtime_amount = 32
@export var room_starts_in_uptime = false
@export var respawn_starts_in_uptime = false


var active = false


@onready var mat_uptime : ParticleProcessMaterial = wind_particles_uptime.get_process_material()
@onready var mat_downtime : ParticleProcessMaterial = wind_particles_downtime.get_process_material()

func _ready():
	mat_uptime.direction = Vector3(wind_direction.x, wind_direction.y, 0.0)
	mat_uptime.initial_velocity_min = min_speed_uptime
	mat_uptime.initial_velocity_max = max_speed_uptime
	wind_particles_uptime.amount = uptime_amount
	Events.connect("player_dead", wind_reset)
	Events.connect("player_first_move_after_respawn",start_timer_after_respawn)
	

func _physics_process(delta: float) -> void:
	if active and !uptime_timer.is_stopped():
		#print("Wind ", windspeed * wind_direction )
		player.velocity += windspeed * wind_direction

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Player entered wind")
		player = body
		active = true
		
		if room_starts_in_uptime:
			wind_particles_uptime.emitting = true
			uptime_timer.start(uptime)
		else:
			wind_particles_downtime.emitting = true
			downtime_timer.start(downtime)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		print("Player left wind")
		active = false
		player = null
		uptime_timer.stop()
		downtime_timer.stop()
		wind_particles_uptime.emitting = false
		wind_particles_downtime.emitting = false


func _on_uptime_timeout() -> void:
	wind_particles_uptime.emitting = false
	wind_particles_downtime.emitting = true
	downtime_timer.start(downtime)

func _on_downtime_timeout() -> void:
	wind_particles_downtime.emitting = false
	wind_particles_uptime.emitting = true
	uptime_timer.start(uptime)

func wind_reset():
	uptime_timer.stop()
	downtime_timer.stop()
	wind_particles_downtime.emitting = true
	wind_particles_uptime.emitting = false

func start_timer_after_respawn():
	if active:
		if respawn_starts_in_uptime:
			uptime_timer.start(uptime)
			wind_particles_downtime.emitting = false
			wind_particles_uptime.emitting = true
		else:
			wind_particles_uptime.emitting = false
			wind_particles_downtime.emitting = true
			downtime_timer.start(downtime)
