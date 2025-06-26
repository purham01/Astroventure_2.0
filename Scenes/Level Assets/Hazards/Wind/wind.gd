extends Area2D

var player : CharacterBody2D = null
@export var wind_speed : float =  60.0
@export var wind_acceleration : float =  600.0
@export var uptime : float
@export var downtime : float
@export var wind_direction : Vector2
#@export var wind_particles : GPUParticles2D

@onready var wind_particles_uptime: GPUParticles2D = $CanvasLayer/WindParticlesUptime
@onready var wind_particles_downtime: GPUParticles2D = $CanvasLayer/WindParticlesDowntime
@onready var uptime_timer: Timer = $UptimeTimer
@onready var downtime_timer: Timer = $DowntimeTimer
@onready var wind_trail_downtime: GPUParticles2D = $CanvasLayer/WindTrailDowntime
@onready var wind_trail_uptime: GPUParticles2D = $CanvasLayer/WindTrailUptime

@export_category("Functionality")
@export var room_starts_in_uptime = false
@export var respawn_starts_in_uptime = false
@export var disable = false

@export_category("Multipliers")
@export var speed_mul = 0.3
@export var acceleration_mul = 0.8
@export var speed_mul_dir = 2
@export var acceleration_mul_dir = 1

@export_category("Particles")
@export var min_speed_uptime = 50.0
@export var max_speed_uptime = 200.0
@export var min_speed_downtime = 10.0
@export var max_speed_downtime = 20.0
@export var uptime_amount = 100
@export var downtime_amount = 50


var active = false



@onready var mat_uptime : ParticleProcessMaterial = wind_particles_uptime.get_process_material()
@onready var mat_downtime : ParticleProcessMaterial = wind_particles_downtime.get_process_material()
@onready var mat_trail_uptime : ParticleProcessMaterial = wind_trail_uptime.get_process_material()
@onready var mat_trail_downtime : ParticleProcessMaterial = wind_trail_downtime.get_process_material()

func _ready():
	
	mat_uptime.direction = Vector3(wind_direction.x, 0.0, 0.0)
	mat_trail_uptime.gravity.x *= wind_direction.x
	#mat_uptime.initial_velocity_min = min_speed_uptime
	#mat_uptime.initial_velocity_max = max_speed_uptime
	#wind_particles_uptime.amount = uptime_amount
	
	mat_downtime.direction = Vector3(wind_direction.x, 0.0, 0.0)
	mat_trail_downtime.gravity.x *= wind_direction.x
	#mat_downtime.initial_velocity_min = min_speed_uptime
	#mat_downtime.initial_velocity_max = max_speed_uptime
	#wind_particles_downtime.amount = downtime_amount
	
	Events.connect("player_dead", wind_reset)
	Events.connect("player_first_move_after_respawn",start_timer_after_respawn)
	

func _physics_process(delta: float) -> void:
	if player != null and !disable:
		if active and !uptime_timer.is_stopped():
			player.terrain_sm.friction_multiplier = 0.0
			if player.movement_input.x == wind_direction.x:
			#print("Wind ", windspeed * wind_direction )
				player.terrain_sm.acceleration_multiplier = acceleration_mul_dir
				player.terrain_sm.speed_multiplier = speed_mul_dir
			elif player.movement_input.x == -wind_direction.x:
				player.terrain_sm.acceleration_multiplier = acceleration_mul
				player.terrain_sm.speed_multiplier = speed_mul
			else:
				player.terrain_sm.acceleration_multiplier = 1
				player.terrain_sm.speed_multiplier = 1
			
			
			player.velocity.x = move_toward(player.velocity.x, wind_speed * wind_direction.x,  wind_acceleration * delta)
		else:
			player.terrain_sm.friction_multiplier = player.terrain_sm.base_friction_multiplier
			player.terrain_sm.speed_multiplier =  player.terrain_sm.base_speed_multiplier
			player.terrain_sm.acceleration_multiplier = player.terrain_sm.base_acceleration_multiplier
		
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and !disable:
		print("Player entered wind")
		player = body
		active = true
		
		if room_starts_in_uptime:
			wind_particles_uptime.emitting = true
			wind_trail_uptime.emitting = true
			uptime_timer.start(uptime)
		else:
			wind_trail_downtime.emitting = true
			wind_particles_downtime.emitting = true
			downtime_timer.start(downtime)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" and !disable:
		print("Player left wind")
		active = false
		player.terrain_sm.friction_multiplier = player.terrain_sm.base_friction_multiplier
		player.terrain_sm.speed_multiplier =  player.terrain_sm.base_speed_multiplier
		player.terrain_sm.acceleration_multiplier = player.terrain_sm.base_acceleration_multiplier
	
		
		player = null
		uptime_timer.stop()
		downtime_timer.stop()
		wind_particles_uptime.emitting = false
		wind_particles_downtime.emitting = false
		wind_trail_uptime.emitting = false
		wind_trail_downtime.emitting = false
	

func _on_uptime_timeout() -> void:
	wind_trail_uptime.emitting = false
	wind_trail_downtime.emitting = true
	
	wind_particles_uptime.emitting = false
	wind_particles_downtime.emitting = true
	downtime_timer.start(downtime)

func _on_downtime_timeout() -> void:
	wind_trail_uptime.emitting = true
	wind_trail_downtime.emitting = false
	
	wind_particles_downtime.emitting = false
	wind_particles_uptime.emitting = true
	uptime_timer.start(uptime)

func wind_reset():
	uptime_timer.stop()
	downtime_timer.stop()
	
	wind_trail_uptime.emitting = false
	wind_trail_downtime.emitting = true
	
	wind_particles_downtime.emitting = true
	wind_particles_uptime.emitting = false

func start_timer_after_respawn():
	if active:
		if respawn_starts_in_uptime:
			uptime_timer.start(uptime)
			
			wind_trail_uptime.emitting = true
			wind_trail_downtime.emitting = false
			
			wind_particles_downtime.emitting = false
			wind_particles_uptime.emitting = true
		else:
			downtime_timer.start(downtime)
