extends Node2D

@export var retracted = false
@onready var animation_player = $AnimationPlayer

func _ready():
	$RetractExtendTimer.start()
	if !retracted:
		animation_player.play("show")
	else:
		animation_player.play("hide")

func _on_retract_extend_timer_timeout():
	if retracted:
		animation_player.play("hide")
	else:
		animation_player.play("show")
	


func set_collision(value):
	$HazardArea.set_collision_layer_value(3, value)
	retracted = !retracted
