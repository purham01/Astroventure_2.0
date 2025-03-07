extends CharacterBody2D

#player input
var movement_input = Vector2.ZERO
var jump_input = false
var jump_input_actuation = false
var climb_input = false
var dash_input = false


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

#player movement
const SPEED = 6 * Globals.UNIT_SIZE
var last_direction = Vector2.RIGHT

#jumping
@export var max_jump_height : float
@export var min_jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_fall : float

@onready var max_jump_velocity : float = ((2.0 * max_jump_height * Globals.UNIT_SIZE) / jump_time_to_peak) * -1.0 
@onready var min_jump_velocity : float = ((2.0 * min_jump_height * Globals.UNIT_SIZE) / jump_time_to_peak) * -1.0 
@onready var jump_gravity : float = ((-2.0 * max_jump_height * Globals.UNIT_SIZE ) / (jump_time_to_peak * jump_time_to_peak))  * -1.0 
@onready var fall_gravity : float = ((-2.0 * max_jump_height * Globals.UNIT_SIZE) / (jump_time_to_fall * jump_time_to_fall))  * -1.0 



#states
var current_state = null
var prev_state = null

#mechanics
var can_dash = true

#nodes
@onready var STATES = $STATES
@onready var raycasts: Node2D = $Raycasts


@onready var state_info: Label = $StateInfo
@onready var jump_actuation_info: Label = $JumpActuationInfo
@onready var jump_info: Label = $JumpInfo


func _ready() -> void:
	for state in STATES.get_children():
		state.STATES = STATES
		state.Player = self
	current_state = STATES.idle
	prev_state = STATES.idle

func _physics_process(delta: float) -> void:
	player_input()
	change_state(current_state.update(delta))
	state_info.text = str(current_state.get_name())
	jump_actuation_info.text = str(jump_input_actuation)
	jump_info.text = str(jump_input)
	move_and_slide()
	print("player velocity: ",velocity)
	_assign_animation()

func gravity(delta):
	if not is_on_floor():
		velocity.y += get_my_gravity() * delta

func get_my_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func change_state(input_state):
	if (input_state != null):
		prev_state = current_state
		current_state = input_state
		
		prev_state.exit_state()
		current_state.enter_state()

func get_next_to_wall():
	for raycast_group in raycasts.get_children():
		for raycast : RayCast2D in raycast_group.get_children():
			raycast.force_raycast_update()
			if raycast.is_colliding():
				if raycast.target_position.x > 0:
					return Vector2.RIGHT
				else:
					return Vector2.LEFT
	return null
	

	
func player_input():
	movement_input.x = Input.get_axis("MoveLeft","MoveRight")
	movement_input.y = Input.get_axis("MoveUp","MoveDown")
	jump_input_actuation = Input.is_action_just_pressed("Jump")
	jump_input = Input.is_action_pressed("Jump")
	dash_input = Input.is_action_just_pressed("Dash")
	climb_input = Input.is_action_pressed("Climb")

func _assign_animation():
	if movement_input.x != 0:
		animated_sprite.flip_h = (movement_input.x<0)

	if !is_on_floor():
		animated_sprite.play("jump")
	elif movement_input.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
