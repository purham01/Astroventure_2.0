extends StateMachine

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	call_deferred("set_state",states.idle)

func _state_logic(delta):
	parent._update_move_direction()
	parent._update_wall_direction()
	if state != states.wall_slide:
		parent._apply_movement(delta)
	parent.gravity(delta)
	if state == states.wall_slide:
		parent._cap_gravity_wall_slide()
		parent._handle_wall_slide_sticking()
	parent._assign_animation()
	parent.move_and_slide()

func _input(event: InputEvent) -> void:
	if [states.idle, states.run].has(state):
		if event.is_action_pressed("Jump"):
			if Input.is_action_pressed("MoveDown"):
				if parent._check_is_droppable():
					parent.set_collision_mask_value(parent.DROP_THRU_BIT, false)
					#print("Drop bit disabled")
			else:
				parent.velocity.y = parent.max_jump_velocity
				
	#Variable jump
	if [states.jump].has(state):
		if event.is_action_released("Jump") and parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity 

	if [states.wall_slide].has(state):
		if event.is_action_pressed("Jump"):
			parent.wall_jump()
			
			set_state(states.jump)


func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		states.wall_slide:
			if parent.is_on_floor():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
		
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite.play("idle")
		states.run:
			parent.animated_sprite.play("run")
		states.fall:
			parent.animated_sprite.play("jump")
		states.jump:
			parent.animated_sprite.play("jump")
		states.wall_slide:
			parent.animated_sprite.play("jump")
			

func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wall_slide_cooldown.start()


func _on_wall_slide_sticky_timer_timeout() -> void:
	if state == states.wall_slide:
		set_state(states.fall)
