@tool
extends Node2D

const MAX_LENGTH = 2000

#@onready var sender = get_parent()

@export var bounces = 1
@export var active_time = 3.00 
@export var cooldown_time = 3.00

@export var start_delay_bool = false 
@export var start_delay_time = 0.5

@onready var laser: RayCast2D = $Laser
@onready var line: Line2D = $Line2D
@onready var end: GPUParticles2D = $End

@onready var active_timer: Timer = $ActiveTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var start_delay: Timer = $StartDelay
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var max_target_position
@export var rot = 0.0

var lasers = []

var active = false
var can_damage = false

var objects_collide = []

func _ready() -> void:
	
	lasers.append(laser)
	
	for i in range(bounces):
		
		#make a new raycast for each bounce and append it to the array
		var raycast : RayCast2D = laser.duplicate()
		raycast.enabled = false
		#raycast.add_exception(sender)
		add_child(raycast)
		lasers.append(raycast)
	
	max_target_position = Vector2(MAX_LENGTH, 0).rotated(rot)
	laser.target_position = max_target_position
	
	if start_delay_bool:
		start_delay.start(start_delay_time)
	else:
		animation_player.play("charge_up")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	
	if active:
		draw_lasers()

func _draw() -> void:
	if !Engine.is_editor_hint():
		return

	var space_state = get_world_2d().direct_space_state
	var from = global_position
	var direction = Vector2.RIGHT.rotated(rot)
	var current_dir = direction.normalized() * MAX_LENGTH
	var points = [from]

	for i in range(bounces + 1):
		var to = from + current_dir

		var params = PhysicsRayQueryParameters2D.create(from, to)
		params.exclude = [self]
		params.collision_mask = 0b1

		var result = space_state.intersect_ray(params)

		if result:
			#print("Hit object: ", result.collider.name, " on layers: ", result.collider.collision_layer)
			
			var hit_point = result.position
			var normal = result.normal

			points.append(hit_point)

			#print("Bounce ", i, ": hit at ", hit_point, " with normal ", normal)

			# Bounce
			current_dir = current_dir.bounce(normal).normalized() * MAX_LENGTH
			from = hit_point + normal * 0.1
		else:
			points.append(to)
			break

	# Draw it
	for i in range(points.size() - 1):
		draw_line(to_local(points[i]), to_local(points[i + 1]), Color.RED, 2.0)


func draw_lasers():
		
	#get rotation
	#rot = get_local_mouse_position().angle()
	#rot = laser.target_position.angle()
	
	#reset points
	line.clear_points()
	
	line.add_point(global_position)
	
	max_target_position = Vector2(MAX_LENGTH,0).rotated(rot)
	
	var idx = -1
	for raycast : RayCast2D in lasers:
		
		idx +=1 
		var raycastcollision = raycast.get_collision_point()
		
		raycast.target_position = max_target_position
		
		if raycast.is_colliding():
			
			var collider = raycast.get_collider()
			#print("Collider: ", collider)
			
			if collider == null:
				return
			
			if collider.is_in_group("Player"):
				if can_damage:
					collider.respawn()
				
				objects_collide.append( collider ) #add it to the array.
				raycast.add_exception( collider ) #add to ray's exception. That way it could detect something being behind it.
				raycast.force_raycast_update() #update the ray's collision query.
				
				raycastcollision = raycast.get_collision_point()
				raycast.target_position = max_target_position


			#place next line point at the collision point
			line.add_point(raycastcollision)
			max_target_position = max_target_position.bounce(raycast.get_collision_normal())

			if idx < lasers.size()-1: # if not last raycast, enable next raycast
				lasers[idx+1].enabled = true
				lasers[idx+1].global_position = raycastcollision+(1*max_target_position.normalized())
			if idx == lasers.size()-1: #if last raycast, set end particle to collision
				end.global_position = raycastcollision
		
		#no collision
		else:
			line.add_point(global_position + max_target_position)
			
			if idx == 0:
				raycast.target_position = max_target_position
				end.global_position = global_position+max_target_position
			else:
				end.global_position = raycast.global_position+max_target_position
		
		
		#after all is done, remove the objects from ray's exception.
		for obj in objects_collide:
			raycast.remove_exception( obj )




func _on_active_timer_timeout() -> void:
	if active:
		line.clear_points()

	animation_player.play("shut_down")

func _on_cooldown_timer_timeout() -> void:
	animation_player.play("charge_up")

func set_can_damage(value : bool):
	can_damage = value

func set_active(value : bool):
	active = value

func start_cooldown_timer():
	cooldown_timer.start(cooldown_time)
	
func start_active_timer():
	active_timer.start(active_time)
	

func switch_emitting_particles():
	end.emitting = !end.emitting


func _on_start_delay_timeout() -> void:
	animation_player.play("charge_up")
