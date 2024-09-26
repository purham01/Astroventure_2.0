extends ProgressBar

@export var player : CharacterBody2D
@export var MAX_VALUE : int = 30

var timer_enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer_enabled:
		visible = true
		value -= 1 * delta
	else:
		visible = false
		reset()
	if value <= 0:
		reset()
		player.respawn();

func reset():
	value = MAX_VALUE

func enable():
	timer_enabled = true

func disable():
	timer_enabled = false

func _on_startheat_timer_body_entered(body):
	if body.is_in_group("Player"):
		
		enable()


func _on_startheat_timer_body_exited(body):
	if body.is_in_group("Player"):
		disable()
