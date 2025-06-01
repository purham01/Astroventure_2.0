extends Camera2D

# Amount of smoothing used to follow the player value is from 0 to 1
@export var follow_smoothing: float = 0.1

# The amount of smoothing used by the code
var smoothing: float

var current_room_center: Vector2
var current_room_size: Vector2

@onready var view_size: Vector2 = get_viewport_rect().size
var zoom_view_size: Vector2

@onready var player := get_tree().current_scene.get_node("Player")
 
var room_pause: bool = false
@export var room_pause_time: float = 0.5

#shake
@export var shakeFade: float = 10.0
var rng = RandomNumberGenerator.new()
var shakeStrength: float = 0.0

@export var camera_transition_duration = 1.0

@onready var shake_timer: Timer = $Timer

func _ready() -> void:
	# Sets smoothing to 1 and back to follow_smoothing
	# I do this so the camera appears as if it starts at the first room not at (0, 0)

	position_smoothing_enabled = false
	smoothing = 1
	await get_tree().create_timer(0.1).timeout
	smoothing = follow_smoothing
	setup_antigravity()
	CameraShake.player_camera = self
	CameraShake.camera_transition_duration = camera_transition_duration


func _physics_process(delta: float) -> void:
	# Get view size considering camera zoom
	zoom_view_size = view_size * zoom
	
	var target_position
	# Get target position
	if player.current_gs == player.GRAVITY_STATES.down or player.current_gs == player.GRAVITY_STATES.up:
		target_position = calculate_target_position(current_room_center, current_room_size)
	else:
		target_position = calculate_target_position_grav_x(current_room_center, current_room_size)
	# Interpolate(lerp) camera position to target position by the smoothing
	position = lerp(position, target_position, smoothing)
	
	if shakeStrength > 0:
		if shake_timer.is_stopped():
			shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		offset = randomOffset()

func calculate_target_position(room_center: Vector2, room_size: Vector2) -> Vector2:
	# The distance from the center of the room to the camera boundary on one side.
	# When the room is the same size as the screen the x and y margin are zero
	var x_margin: float = (room_size.x - zoom_view_size.x) / 2
	var y_margin: float = (room_size.y - zoom_view_size.y) / 2
	
	
	var return_position: Vector2 = Vector2.ZERO
	
	# if the zoom_view_size >= room_size the camera position should just be room center
	if x_margin <= 0:
		return_position.x = room_center.x
	# Clamps the return position to the left and right limits if the x_margin is positive
	else:
		var left_limit: float = room_center.x - x_margin
		var right_limit: float = room_center.x + x_margin
		return_position.x = clamp(player.position.x, left_limit, right_limit)


	if y_margin <= 0:
		return_position.y = room_center.y
	else:
		var top_limit: float = room_center.y - y_margin
		var bottom_limit: float = room_center.y + y_margin
		return_position.y = clamp(player.position.y, top_limit, bottom_limit)
	
	return return_position

func calculate_target_position_grav_x(room_center: Vector2, room_size: Vector2) -> Vector2:
	# The distance from the center of the room to the camera boundary on one side.
	# When the room is the same size as the screen the x and y margin are zero
	var x_margin: float = (room_size.x - zoom_view_size.y) / 2
	var y_margin: float = (room_size.y - zoom_view_size.x) / 2
	
	#print("X margin: ",x_margin)
	#print("Y margin: ", y_margin)
	var return_position: Vector2 = Vector2.ZERO
	
	# if the zoom_view_size >= room_size the camera position should just be room center
	if x_margin <= 0:
		return_position.x = room_center.x
	# Clamps the return position to the left and right limits if the x_margin is positive
	else:
		var left_limit: float = room_center.x - x_margin
		var right_limit: float = room_center.x + x_margin
		return_position.x = clamp(player.position.x, left_limit, right_limit)


	if y_margin <= 0:
		return_position.y = room_center.y
	else:
		var top_limit: float = room_center.y - y_margin
		var bottom_limit: float = room_center.y + y_margin
		return_position.y = clamp(player.position.y, top_limit, bottom_limit)
	
	return return_position

func change_room(room_position: Vector2, room_size: Vector2) -> void:
	current_room_center = room_position
	current_room_size = room_size

	#room_pause = true
	Engine.time_scale = 0
	await get_tree().create_timer(room_pause_time, true, false, true).timeout
	Engine.time_scale = 1
	#room_pause = false


func apply_shake(randomStrength = 30.0, shake_duration = 0.0):
	shakeStrength = randomStrength
	if shake_duration > 0.0:
		shake_timer.start(shake_duration)
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))


func setup_antigravity():
	Events.connect("change_gravity", change_gravity)

func change_gravity(new_rotation_degrees):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	#print( abs(rotation_degrees - new_rotation_degrees))
	#print("New rotation: ",new_rotation_degrees)
	if new_rotation_degrees == 0 and rotation_degrees == 270:
		new_rotation_degrees = 360
	elif abs(rotation_degrees - new_rotation_degrees) > 180:
		new_rotation_degrees = new_rotation_degrees - 360
	#print("Current rotation: ", rotation_degrees)
	#print("New rotation: ",new_rotation_degrees)
	
	tween.tween_property(self, "rotation_degrees", new_rotation_degrees, camera_transition_duration)
	await tween.finished
	if rotation_degrees == -360 or rotation_degrees == 360:
		rotation_degrees = 0
