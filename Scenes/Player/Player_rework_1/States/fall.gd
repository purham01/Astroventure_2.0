extends "state.gd"

@onready var coyote_time: Timer = $CoyoteTime
@export var coyote_duration = 0.2
var can_jump = true

func update(delta):
	Player.current_gs.gravity(delta)
	Player.player_movement(delta)
	
	if  Player.dash_input and Player.can_dash:
		return STATES.dash
	
	if Player.is_on_floor() and !Player.jump_buffer.is_stopped():
		return STATES.jump
		
	elif Player.is_on_floor():
		Player.animated_sprite.scale = Vector2(Player.squash_x, Player.squash_y)
		return STATES.idle
		
	if Player.wall_direction != 0 and Player.climb_input and Player.current_stamina > 0:
		return STATES.climb
	
	#no stamina wall slide
	if Player.climb_input and Player.current_stamina <= 0 and Player.wall_direction != 0 and Player.wall_slide_cooldown.is_stopped():
		return STATES.wall_slide
	
	#has stamina wall slide
	if sign(Player.movement_input.x) == sign(Player.wall_direction) and Player.wall_direction != 0 and Player.wall_slide_cooldown.is_stopped():
		return STATES.wall_slide
		
	if Player.wall_direction != 0 and Player.jump_input_actuation:
		return STATES.wall_jump
		
	if Player.jump_input_actuation and can_jump:
		return STATES.jump
		
	return null
#

func enter_state():
	if Player.prev_state == STATES.idle or Player.prev_state == STATES.move or Player.prev_state == STATES.wall_slide:
		can_jump = true
		coyote_time.start(coyote_duration)
	else:
		can_jump = false


func _on_coyote_time_timeout() -> void:
	can_jump = false
