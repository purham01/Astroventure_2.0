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

@export var launch_velocity = Vector2(200, 100)

var speed = 0.0
var moving_forward = false
var moving_backward = false
var dont_boost = false

var player_on_top = null
var player_on_side = null
var last_velocity = Vector2.ZERO
@onready var direction_modificator = 1.0 if start_point.position.direction_to(destination_point.position) <= Vector2.ZERO else -1.0

var movement_direction 
var previous_position

@export var wiggle_room_time = 0.2
@export var threshold = 2.0

func _ready() -> void:
	
	movement_direction = start_point.global_position.direction_to(destination_point.global_position)
	#print("")
	#print(name)
	#print("Movement direction " + str(movement_direction))
	#print("Comparison <= vs vector0 ", start_point.position.direction_to(destination_point.position) <= Vector2.ZERO)
	#print("Movement direction back " + str(destination_point.position.direction_to(start_point.position) ))
	Events.player_dead.connect(reset)


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
		#print("Reached end, going back")
		speed = 0.0
		moving_forward = false
		wiggle_room_timer.start(wiggle_room_time)
		await get_tree().create_timer(time_to_turn).timeout
		moving_backward = true

	elif moving_backward and platform.position.direction_to(start_point.position) == Vector2.ZERO:
		platform.position = start_point.position
		#print("Reached start")
		speed = 0.0
		moving_backward = false
		if player_on_top != null:
			await get_tree().create_timer(time_to_reset).timeout
			moving_forward = true
		

func check_player_climb():
	
	if player_on_side != null:
		if player_on_side.current_state == player_on_side.STATES.climb and !moving_backward and !moving_forward:
			moving_forward = true
		if player_on_side.current_state == player_on_side.STATES.jump:
			_on_player_on_side_body_exited(player_on_side)
		
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
		#last_velocity = PhysicsServer2D.body_get_state(platform.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY)
	
	if moving_backward:
		direction = destination_point.position.direction_to(start_point.position)
		if (platform.position + direction * speed * delta).direction_to(start_point.position) * direction_modificator <= Vector2.ZERO:
			platform.position = start_point.position
		else:
			platform.position += direction * speed * delta
		#last_velocity = PhysicsServer2D.body_get_state(platform.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY)


func _on_player_on_top_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if !moving_backward:
			moving_forward = true
		if platform.global_position.distance_to(start_point.global_position) > start_point.global_position.distance_to(destination_point.global_position)/threshold:
			dont_boost = true
		else:
			dont_boost = false
		player_on_top = body
		#player_on_side = null
		#print("Player on platform")


func _on_player_on_top_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		if player_on_top == null:
			return
		#var platform_speed = PhysicsServer2D.body_get_state(platform.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY)
		#print("platform velocity: ", platform_speed)
		#print(movement_direction)
		#print(platform.global_position.distance_to(start_point.global_position))
		#print(start_point.global_position.distance_to(destination_point.global_position))
		#print(start_point.global_position.distance_to(destination_point.global_position)/threshold)
		#print(start_point.global_position.distance_to(destination_point.global_position)/(threshold*2))
		
		if body.current_state != body.STATES.jump or dont_boost:
			player_on_top = null
			dont_boost = false
			wiggle_room_timer.stop()
			return
		else:
			player_on_top.change_state(player_on_top.STATES.special_jump)
		
		if !wiggle_room_timer.is_stopped() or (moving_forward and platform.global_position.distance_to(start_point.global_position) > start_point.global_position.distance_to(destination_point.global_position)/threshold):
			#print("Last velocity ", last_velocity)
			player_on_top.velocity.x = launch_velocity.x * movement_direction.x
			player_on_top.velocity.y = player_on_top.max_jump_velocity + launch_velocity.y * movement_direction.y 
		elif (moving_forward and platform.global_position.distance_to(start_point.global_position) > start_point.global_position.distance_to(destination_point.global_position)/(2*threshold)):
			player_on_top.velocity.x = launch_velocity.x/2 * movement_direction.x
			player_on_top.velocity.y = player_on_top.max_jump_velocity + launch_velocity.y/2 * movement_direction.y 
		player_on_top = null
		dont_boost = false
		wiggle_room_timer.stop()
		#print("Player left platform")
		
			
			


func _on_player_on_side_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_on_side = body
		print("player on side active")
		print(player_on_side)


func _on_player_on_side_body_exited(body: Node2D) -> void:
	
	print("player on side deactivating")
	print(player_on_side)
	#print(platform.global_position.distance_to(start_point.global_position))
	#print(start_point.global_position.distance_to(destination_point.global_position))
	#print(start_point.global_position.distance_to(destination_point.global_position)/threshold)
	#print(start_point.global_position.distance_to(destination_point.global_position)/(threshold*2))
	
	
	
	if body.name == "Player":
		if player_on_side == null:
			return
		
		if (body.prev_state != body.STATES.climb and body.current_state != body.STATES.jump) or dont_boost:
			player_on_side = null
			dont_boost = false
			wiggle_room_timer.stop()
			return
		else:
			player_on_side.change_state(player_on_side.STATES.special_jump)
		
		
		print("Launching player")
		print(launch_velocity.y * movement_direction.y)
		print(player_on_side.max_jump_velocity + launch_velocity.y * movement_direction.y)
		if !wiggle_room_timer.is_stopped() or (moving_forward and platform.global_position.distance_to(start_point.global_position) > start_point.global_position.distance_to(destination_point.global_position)/threshold):
			#print("Last velocity ", last_velocity
			player_on_side.velocity.y = player_on_side.max_jump_velocity + launch_velocity.y * movement_direction.y
		elif (moving_forward and platform.global_position.distance_to(start_point.global_position) >  start_point.global_position.distance_to(destination_point.global_position)/(2*threshold)):
			player_on_side.velocity.y = player_on_side.max_jump_velocity + launch_velocity.y/2 * movement_direction.y
		dont_boost = false
		wiggle_room_timer.stop()
		player_on_side = null

func reset():
	platform.position = start_point.position
	speed = 0.0
	moving_backward = false
	moving_forward = false
	player_on_top = null
	player_on_side = null
	wiggle_room_timer.stop()
