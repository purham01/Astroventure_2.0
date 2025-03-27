extends Area2D

@export var floating_text : PackedScene

@onready var animation_player = $AnimationPlayer

@onready var starting_position = global_position

signal pick_up

var follow_player = false
var speed = 20
#@onready var player = get_tree().get_root().get_node("World/Player")
@onready var collision_shape_2d = $CollisionShape2D
var star_location
var player
var can_pick_up = false
var picking_up = false

func _ready():
	Events.pickup_stars.connect(pickup)
	Events.player_dead.connect(reset_position)

func _physics_process(delta):
	if !picking_up:
		if !follow_player and global_position!=starting_position:
			global_position = global_position.lerp(starting_position, 0.08)
		if follow_player and star_location != null:
			#print("Following player, hopefully")
			global_position = global_position.lerp(star_location.global_position, 0.08)
			
			#TODO dodati ove stvari za gravitaciju poslije
			#if player.GravityDirection == player.GravityDirections.DOWN:
				#rotation_degrees = 0
			#elif player.GravityDirection == player.GravityDirections.UP:
				#rotation_degrees = 180
			#elif player.GravityDirection == player.GravityDirections.RIGHT:
				#rotation_degrees = -90
			#elif player.GravityDirection == player.GravityDirections.LEFT:
				#rotation_degrees = 90

func _on_body_entered(body):
	player = body
	star_location = Marker2D.new()
	player.follower_controller.star_container.add_child(star_location)
	star_location.position = Vector2(player.follower_controller.star_counter*-13,player.follower_controller.star_counter%2*-6)
	player.follower_controller.star_counter += 1
	follow_player = true
	collision_shape_2d.set_deferred("disabled", true)
	
	

func reset_position():
	if follow_player == true:
		print("Player dead, resetting heart")
		follow_player = false
		star_location.queue_free()
		collision_shape_2d.set_deferred("disabled", false)
		rotation_degrees = 0


func pickup():
	#print("Picking up hearts")
	if follow_player:
		picking_up = true
		follow_player = false
		var stars = get_tree().get_nodes_in_group("Stars")
		print(stars.size())
		animation_player.play("pickup")
		pick_up.emit()
		Events.update_score.emit()


func _on_animated_sprite_2d_animation_finished():
	if star_location != null:
		star_location.queue_free()
	queue_free()


func show_popup():
	var text = floating_text.instantiate()
	text.position = $TextMarker.global_position
	
	get_tree().current_scene.add_child(text)
