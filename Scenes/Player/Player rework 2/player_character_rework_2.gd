extends CharacterBody2D



var DROP_THRU_BIT = 4

#jumping
var max_jump_velocity 
var min_jump_velocity
var my_gravity

var max_jump_height = Globals.UNIT_SIZE * 3.2
var min_jump_height = Globals.UNIT_SIZE * 0.5
var jump_duration = 0.5

var movement_input = 0
var move_speed = 6 * Globals.UNIT_SIZE

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

@onready var wall_slide_cooldown: Timer = $WallSlideCooldown

@onready var wall_slide_sticky_timer: Timer = $WallSlideStickyTimer
@onready var right_wall_raycasts: Node2D = $Raycasts/Right
@onready var left_wall_raycasts: Node2D = $Raycasts/Left
var wall_direction = 1
var WALL_JUMP_VELOCITY = Vector2(6 * Globals.UNIT_SIZE,-Globals.UNIT_SIZE * 10)

func _ready() -> void:
	my_gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * my_gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * my_gravity * min_jump_height)


func _apply_movement(delta):
	player_input(delta)
	

func gravity(delta):
	if not is_on_floor():
		velocity.y += my_gravity * delta
		
func _update_move_direction():
	movement_input = Input.get_axis("MoveLeft","MoveRight")


func player_input(delta):
	velocity.x = lerp(velocity.x, move_speed*movement_input, _get_h_weight())
	if movement_input == 0:
		if (velocity.x < 0 && velocity.x > -1) || (velocity.x > 0 && velocity.x < 1):
			velocity.x = 0

	
func _get_h_weight():
	if is_on_floor():
		return 0.2
	else:
		if movement_input == 0:
			return 0.02
		elif movement_input == sign(velocity.x) && abs(velocity.x) > move_speed:
			return 0.0
		else:
			return 0.1

func wall_jump():
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity
	if movement_input == 0:
		animated_sprite.flip_h = (wall_direction>0)

func _assign_animation():
	if movement_input != 0:
		animated_sprite.flip_h = (movement_input<0)

func _check_is_droppable():
	for raycast : RayCast2D in $DropThruRaycasts.get_children():
		if raycast.is_colliding():
			return true

func _on_drop_detection_area_exited(area: Area2D) -> void:
	set_collision_mask_value(DROP_THRU_BIT, true)
	#print("Drop bit enabled")

func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	
	if is_near_wall_left and is_near_wall_right:
		wall_direction = movement_input
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)


func _check_is_valid_wall(wall_raycasts):
	for raycast : RayCast2D in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				return true
	return false

func _cap_gravity_wall_slide():
	var max_velocity = Globals.UNIT_SIZE if !Input.is_action_pressed("MoveDown") else 6 * Globals.UNIT_SIZE
	velocity.y = min(velocity.y, max_velocity)

func _handle_wall_slide_sticking():
	if movement_input != 0 && movement_input != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()
