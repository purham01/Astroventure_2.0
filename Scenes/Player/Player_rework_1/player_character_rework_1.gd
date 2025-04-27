extends CharacterBody2D

#player input
var movement_input = Vector2.ZERO
var jump_input = false
var jump_input_actuation = false
var climb_input = false
var dash_input = false

#player movement
const SPEED = 90.0
@export var ACCELARATION = 800.0
@export var FRICTION = 500.0
const AirMult = 0.65
var AIR_ACCELARATION = ACCELARATION * AirMult 
var AIR_RESISTANCE = FRICTION * AirMult
var last_direction = Vector2.RIGHT

#jumping
@export_group("Jumping")

@export var max_jump_height : float 
@export var min_jump_height : float 
@export var jump_time_to_peak : float 
@export var jump_time_to_fall : float 

@onready var max_jump_velocity : float = ((2.0 * max_jump_height * Globals.UNIT_SIZE) / jump_time_to_peak) * -1.0 
@onready var min_jump_velocity : float = ((2.0 * min_jump_height * Globals.UNIT_SIZE) / jump_time_to_peak) * -1.0 
@onready var jump_gravity : float = ((-2.0 * max_jump_height * Globals.UNIT_SIZE ) / (jump_time_to_peak * jump_time_to_peak))  * -1.0 
@onready var fall_gravity : float = ((-2.0 * max_jump_height * Globals.UNIT_SIZE) / (jump_time_to_fall * jump_time_to_fall))  * -1.0 

#celeste variables
@export var half_grav_threshhold = 40.0

const MAX_FALL = 160.0
const FAST_MAX_FALL = 240.0
const FAST_MAX_ACCEL = 300.0

var max_fall = 160

const jump_h_boost = 20
var wall_jump_h_speed = SPEED + 2*jump_h_boost

#wall jumping
@onready var wall_slide_cooldown: Timer = $WallSlideCooldown
@onready var right_wall_raycasts: Node2D = $Raycasts/Right
@onready var left_wall_raycasts: Node2D = $Raycasts/Left
var WALL_JUMP_VELOCITY = Vector2(wall_jump_h_speed, -215)
var WALL_JUMP_VELOCITY_NEUTRAL = Vector2(wall_jump_h_speed/2, -150)
var wall_direction = 1

#animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var flashing_animation_player: AnimationPlayer = $FlashingAnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var shader_animation_player: AnimationPlayer = $ShaderAnimationPlayer

@export_group("Squash")
@export var squish_x = 0.7
@export var squish_y = 1.3
@export var squash_x = 1.2
@export var squash_y = 0.8

#states
var current_state = null
var prev_state = null

#mechanics
var can_dash = true
@export var slide_friction = 0.9
@export var climb_up_speed = -45
@export var climb_down_speed = 80
@export var slide_down_speed = 40
@onready var follower_controller: Node = $FollowerController
@onready var particle_manager: Node = $ParticleManager


#stamina
var max_stamina = 110
var current_stamina = max_stamina
var jump_stamina = 27.5
var hold_stamina = 10.0 #/s
var climb_stamina = 45.45 #/s


#gravity stuff
var current_gs = null
var prev_gs = null

#nodes
@onready var STATES = $STATES
@onready var GRAVITY_STATES: Node = $"GRAVITY STATES"
@onready var raycasts: Node2D = $Raycasts
@onready var jump_buffer: Timer = $JumpBuffer
@onready var dash_buffer: Timer = $DashBuffer
@onready var player_camera := get_tree().current_scene.get_node("PlayerCamera")
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

#debug
@onready var state_info: Label = $StateInfo
@onready var x_speed: Label = $XSpeed
@onready var y_speed: Label = $YSpeed
@onready var stamina_info: Label = $StaminaInfo

#terrain
@onready var terrain_sm : Node = $"TERRAIN SM"

#raycasts
@onready var left_outer: RayCast2D = $CornerCheckRaycasts/LeftOuter
@onready var left_inner: RayCast2D = $CornerCheckRaycasts/LeftInner
@onready var right_inner: RayCast2D = $CornerCheckRaycasts/RightInner
@onready var right_outer: RayCast2D = $CornerCheckRaycasts/RightOuter
var corner_correction_amount = 3 #pixels

#respawn stuff
var playerDead = false
@onready var starting_position = global_position

var endLevel = false

var inTransition = false

func _ready() -> void:
	for state in STATES.get_children():
		state.STATES = STATES
		state.Player = self
	current_state = STATES.idle
	prev_state = STATES.idle
	
	for gravity_state in GRAVITY_STATES.get_children():
		gravity_state.GRAVITY_STATES = GRAVITY_STATES
		gravity_state.Player = self
	current_gs = GRAVITY_STATES.down
	prev_gs = GRAVITY_STATES.down
	
	follower_controller.Player = self
	particle_manager.Player = self
	
	#print(max_jump_velocity)
	#print(min_jump_velocity)
	#print(jump_gravity)
	#print(fall_gravity)
	

func _physics_process(delta: float) -> void:
	squish_reset(delta)
	if !playerDead:
		player_input()
		_update_wall_direction()
		stamina_reset_check()
		change_state(current_state.update(delta))
		calc_max_fall_speed(delta)
		#current_gs.corner_correction(corner_correction_amount)
		current_gs.attempt_correction(3)
		
		handle_jump_buffer()
		
		#debug
		state_info.text = str(current_state.get_name())
		x_speed.text = str(velocity.x)
		y_speed.text = str(velocity.y)
		stamina_info.text =str(current_stamina)
		
		move_and_slide()
		#print("player velocity: ", velocity)
		#print("Wall direction: ", sign(wall_direction))
		#print("Movement input x: ", sign(movement_input.x))
		current_gs._assign_animation(delta)
	#print(is_on_wall())


func stamina_reset_check():
	if current_stamina < 20 and !flashing_animation_player.is_playing():
		flashing_animation_player.play("stamina_flashing")
		
	if is_on_floor():
		stamina_reset()

func stamina_reset():
	current_stamina = max_stamina
	if flashing_animation_player.is_playing():
		flashing_animation_player.stop()

func player_input():
	if ConfigFileHandler.input_type == 0:
		movement_input.x = Input.get_axis("MoveLeft","MoveRight")
		movement_input.y = Input.get_axis("MoveUp","MoveDown")
		jump_input_actuation = Input.is_action_just_pressed("Jump")
		jump_input = Input.is_action_pressed("Jump")
		dash_input = Input.is_action_just_pressed("Dash")
		climb_input = Input.is_action_pressed("Climb")
	else:
		movement_input.x = Input.get_axis("MoveLeftC","MoveRightC")
		movement_input.y = Input.get_axis("MoveUpC","MoveDownC")
		jump_input_actuation = Input.is_action_just_pressed("JumpC")
		jump_input = Input.is_action_pressed("JumpC")
		dash_input = Input.is_action_just_pressed("DashC")
		climb_input = Input.is_action_pressed("ClimbC")

func update_last_direction():
	if movement_input.x > 0:
		last_direction = Vector2.RIGHT
	elif movement_input.x < 0:
		last_direction = Vector2.LEFT

func player_movement(delta):
	update_last_direction()
	current_gs.apply_acceleration(delta)
	current_gs.apply_air_accelaration(delta)
	current_gs.apply_friction(delta)
	current_gs.apply_air_resistance(delta)

func change_state(input_state):
	if (input_state != null):
		prev_state = current_state
		current_state = input_state
		
		prev_state.exit_state()
		current_state.enter_state()

func change_gravity_state(input_state):
	if (input_state != null) and input_state!=current_gs:
		prev_gs = current_gs
		current_gs = input_state
		
		prev_gs.exit_state()
		current_gs.enter_state()

func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	
	if is_near_wall_left and is_near_wall_right:
		wall_direction = movement_input.x
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)

func _check_is_valid_wall(wall_raycasts):
	for raycast : RayCast2D in wall_raycasts.get_children():
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55: 
				return true
	return false

func squish_reset(delta):
	animated_sprite.scale.x = move_toward(animated_sprite.scale.x, 1, 1*delta)
	animated_sprite.scale.y = move_toward(animated_sprite.scale.y, 1, 1*delta)

func calc_max_fall_speed(delta):
	var mf = MAX_FALL
	var fmf = FAST_MAX_FALL
	
	if (ConfigFileHandler.input_type == 0 and Input.is_action_pressed("MoveDown") or (ConfigFileHandler.input_type == 1 and Input.is_action_pressed("MoveDownC"))) and current_state == STATES.fall:
		max_fall = move_toward(max_fall, fmf, FAST_MAX_ACCEL*delta)
		animated_sprite.scale.x = move_toward(animated_sprite.scale.x,squish_x, 0.025);
		animated_sprite.scale.y = move_toward(animated_sprite.scale.y,squish_y, 0.025);
	else:
		max_fall = move_toward(max_fall, mf, FAST_MAX_ACCEL*delta)


func _on_room_detector_area_entered(area: Area2D) -> void:
	# Gets collision shape and size of room
	var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	var size: Vector2 = collision_shape.shape.extents * 2
 

	
	# Changes camera's current room and size. check camera script for more info
	player_camera.change_room(collision_shape.global_position, size)
	
	#adds vertical boost if coming from below
	#TODO
	if area.entrance_from_below:
		current_gs.vertical_boost()
		area.entrance_from_below = false
	

func handle_jump_buffer():
	if !is_on_floor() and jump_input_actuation:
		jump_buffer.start()

func handle_dash_buffer():
	if can_dash and dash_input:
		dash_buffer.start()

func _on_hazard_detector_entered(area: Area2D) -> void:
	respawn()

func _on_hazard_detector_body_entered(body: Node2D) -> void:
	respawn()

func respawn():
	change_state(STATES.dead)
	
func set_spawn(new_position):
	starting_position = new_position
	
func _end_level_anim():
	playerDead = true
	Events.pickup_stars.emit()
	endLevel = true
	animation_player.play("end_level")

func _on_animated_sprite_animation_finished():
	if animated_sprite.animation == "poof" and endLevel:
		animated_sprite.visible= false
