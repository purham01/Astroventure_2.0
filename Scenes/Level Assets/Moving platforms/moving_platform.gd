extends Node2D

@export var MAX_SPEED = 200.0
@export var MAX_BACK_SPEED = 60.0
@export var FORWARD_ACCELERATION = 900.0
@export var BACKWARD_ACCELERATION = 100.0
@export var time_to_turn = 0.5
@export var time_to_reset = 0.2

@onready var start_point: Marker2D = $StartPoint
@onready var destination_point: Marker2D = $DestinationPoint
@onready var platform: AnimatableBody2D = $Platform
@onready var wiggle_room_timer: Timer = $WiggleRoomTimer

@onready var player_camera := get_tree().current_scene.get_node("PlayerCamera")

var speed = 0.0
var moving_forward = false
var moving_backward = false

var player_on_top = null
var player_on_side
var last_velocity = Vector2.ZERO
@onready var direction_modificator = 1.0 if start_point.position.direction_to(destination_point.position) <= Vector2.ZERO else -1.0

var previous_position

func _ready() -> void:
	pass
	#print("")
	#print(name)
	#print("Movement direction " + str(start_point.position.direction_to(destination_point.position) ))
	#print("Comparison <= vs vector0 ", start_point.position.direction_to(destination_point.position) <= Vector2.ZERO)
	#print("Movement direction back " + str(destination_point.position.direction_to(start_point.position) ))



func _physics_process(delta: float) -> void:
	acceleration(delta)
	previous_position = platform.position
	move(delta)
	check_player_climb()
	#print("platform velocity: ", PhysicsServer2D.body_get_state(platform.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY))
	
	#print(platform.position.direction_to(destination_point.position))
	if moving_forward and platform.position.direction_to(destination_point.position) == Vector2.ZERO:
		player_camera.apply_shake(2 * ConfigFileHandler.camera_shake) 
		platform.position = destination_point.position
		print("Reached end, going back")
		speed = 0.0
		moving_forward = false
		wiggle_room_timer.start()
		await get_tree().create_timer(time_to_turn).timeout
		moving_backward = true

	elif moving_backward and platform.position.direction_to(start_point.position) == Vector2.ZERO:
		platform.position = start_point.position
		print("Reached start")
		speed = 0.0
		moving_backward = false
		if player_on_top != null:
			await get_tree().create_timer(time_to_reset).timeout
			moving_forward = true
		

func check_player_climb():
	if player_on_side != null:
		if player_on_side.current_state == player_on_side.STATES.climb and !moving_backward and !moving_forward:
			moving_forward = true
			
func check_player_dash():
	pass

func acceleration(delta: float):
	if moving_forward:
		#print("ACCEL FORWARD")
		speed = move_toward(speed, MAX_SPEED, delta * FORWARD_ACCELERATION)
		
	elif moving_backward:
		#print("ACCEL BACK")
		speed = move_toward(speed, MAX_BACK_SPEED, delta * BACKWARD_ACCELERATION)

func move(delta: float):
	var direction

	
	if moving_forward:
		direction = start_point.position.direction_to(destination_point.position)
		
		
		if (platform.position + direction * speed * delta).direction_to(destination_point.position) * direction_modificator >= Vector2.ZERO:
			platform.position = destination_point.position
		else:
			platform.position += direction * speed * delta
		last_velocity = PhysicsServer2D.body_get_state(platform.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY)
	
	if moving_backward:
		direction = destination_point.position.direction_to(start_point.position)
		if (platform.position + direction * speed * delta).direction_to(start_point.position) * direction_modificator <= Vector2.ZERO:
			platform.position = start_point.position
		else:
			platform.position += direction * speed * delta
		last_velocity = PhysicsServer2D.body_get_state(platform.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY)


func _on_player_on_top_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if !moving_backward:
			moving_forward = true
		player_on_top = body
		#print("Player on platform")


func _on_player_on_top_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		var platform_speed = PhysicsServer2D.body_get_state(platform.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY)
		#print("platform velocity: ", platform_speed)

		if !wiggle_room_timer.is_stopped():
			print("Last velocity ", last_velocity)
			player_on_top.velocity += last_velocity
		player_on_top = null
		#print("Player left platform")
		
			
			


func _on_player_on_side_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_on_side = body
		


func _on_player_on_side_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_on_side = null
