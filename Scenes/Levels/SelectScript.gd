extends Area2D

@export var level : PackedScene
@export var speed = 20
#@export var planet_scale := 1 as float

@onready var path : PathFollow2D = get_parent() as PathFollow2D
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D
@onready var marker = %Marker
@onready var label = %Label
@export var ship : CharacterBody2D 
@onready var animation_player = $AnimationPlayer

enum PlanetNames{
	Mercury,
	Venus,
	Earth,
	Mars,
	Jupiter,
	Saturn,
	Uranus,
	Neptune
}

@onready var UI := get_tree().get_root().get_node("MapScreen/UI") as CanvasLayer
@onready var planet_sprite_frames = $AnimatedSprite2D.sprite_frames
@export var planet_name := PlanetNames.Earth
@onready var planet_name_label = %PlanetName
@onready var planet_name_marker = $PlanetNameMarker
@onready var center_container = %CenterContainer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D


func _ready():
	animation_player.play("RESET")
	#print(UI)
	planet_name_label.text = str(PlanetNames.keys()[planet_name])
	#animated_sprite_2d.scale=planet_scale
	#collision_shape_2d.scale = planet_scale

func _process(delta):
	#center_container.global_position = planet_name_marker.global_position
	path.set_progress(path.get_progress() + speed * delta)
	if not visible_on_screen_notifier_2d.is_on_screen():
		label.visible = true
		var direction_to_planet = ship.global_position.direction_to(global_position)

		marker.position.x = clamp(direction_to_planet.x*360,0+20,360-10)
		marker.position.y = clamp(direction_to_planet.y*180,0,180-10)
		#print(label.text +": "+ str(marker.position))
	else:
		label.visible = false

func _physics_process(delta):
	if has_overlapping_bodies() and !Globals.disable_input:
		if Input.is_action_just_released("ui_accept"):
			get_tree().paused=true
			UI.pass_parameters(level, planet_sprite_frames, planet_name)


func _on_body_entered(body):
	animation_player.play("show_outline")


func _on_body_exited(body):
	animation_player.play("hide_outline")
