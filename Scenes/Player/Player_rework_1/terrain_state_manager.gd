extends Node

#terrain stuff
@export_group("Terrain")
@export var base_friction_multiplier := 1.0
@export var base_speed_multiplier := 1.0
@export var base_acceleration_multiplier := 1.0

@export var ice_speed_multiplier = 1.6
@export var ice_friction_multiplier = 0.1
@export var ice_acceleration_multiplier = 0.2

var friction_multiplier = base_friction_multiplier
var speed_multiplier = base_speed_multiplier
var acceleration_multiplier = base_acceleration_multiplier

@onready var reset_movement_speed_jump_timer: Timer = $"ResetMovementSpeedJump Timer"
var reset_movement

func _physics_process(delta: float) -> void:
	reset_movement_values(delta)

func _on_terrain_detector_terrain_entered(terrain_type):
	reset_movement_speed_jump_timer.stop()
	
	reset_movement = false
	if terrain_type==2:
		#print("Changing movement to ice")
		speed_multiplier = ice_speed_multiplier
		friction_multiplier = ice_friction_multiplier
		acceleration_multiplier= ice_acceleration_multiplier
	elif terrain_type==1:
		#print("Changing movement to normal")
		reset_movement = true
	else:
		#print("Starting reset timer")
		reset_movement_speed_jump_timer.start()

func reset_movement_values(delta):
	if reset_movement:
		speed_multiplier = move_toward(speed_multiplier, base_speed_multiplier, 0.5*delta)
		friction_multiplier = move_toward(friction_multiplier,base_friction_multiplier, 0.5*delta)
		acceleration_multiplier = move_toward(acceleration_multiplier, base_acceleration_multiplier, 0.5*delta)
		
		if speed_multiplier == 1 and friction_multiplier == 1 and acceleration_multiplier == 1:
			reset_movement = false


func _on_reset_movement_speed_jump_timer_timeout() -> void:
	reset_movement = true
