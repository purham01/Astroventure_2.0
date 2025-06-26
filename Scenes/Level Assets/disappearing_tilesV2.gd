extends Node2D

@export var tile_left : Node = null
@export var tile_right : Node = null
@onready var activator_area_active = false
@onready var animation_player = $AnimationPlayer
@onready var return_timer = $ReturnTimer
@onready var activator_area = $ActivatorArea
@onready var sprite: Sprite2D = $Sprite
@onready var shake_timer: Timer = $ShakeTimer

@export var shakeStrength = 1.0
var shake_enable = false

var rng = RandomNumberGenerator.new()

func _ready():
	reset_tiles()
	Events.player_dead.connect(reset_tiles)
	

#func _process(delta):
	#if get_tree().get_root().get_node("World/Player").get("playerDead") and !animation_player.is_playing():
	#	reset_tiles()

func _on_shake_timer_timeout() -> void:
	sprite_shake()

func sprite_shake():
	var shake = Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
	sprite.offset = shake;
	
func reset_tiles():
	if activator_area_active == false:
		sprite.offset = Vector2.ZERO
		shake_timer.stop()
		#print("Reseting tiles")
		animation_player.play_backwards("disappear_2")
		await(animation_player.animation_finished)
		set_activator_area_active(true)


func _on_return_timer_timeout():
	reset_tiles()
	
func set_activator_area_active(value):
	activator_area_active = value


func _on_activator_area_body_entered(body):
	if activator_area_active:
		set_activator_area_active(false)
		animation_player.play("disappear")
		return_timer.start()
		if tile_right != null:
			tile_right._on_activator_area_body_entered(body)
		if tile_left != null:
			tile_left._on_activator_area_body_entered(body)
