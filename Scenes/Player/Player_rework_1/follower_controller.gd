extends Node

@onready var pickup_delay: Timer = $PickupDelay
@onready var star_container: Node2D = $"../StarContainer"

var star_counter = 0
var Player : CharacterBody2D = null


func _physics_process(delta: float) -> void:
	update_star_location()
	check_pickup_stars()

func check_pickup_stars():
	if Player.is_on_floor() and star_counter > 0:
		if pickup_delay.is_stopped():
			pickup_delay.start()
			await(pickup_delay.timeout)
			if !Player.playerDead:
				star_counter = 0
				Events.pickup_stars.emit()

func update_star_location():
	if Player.last_direction.x== 1:
		star_container.position.x = -abs(star_container.position.x)
		star_container.scale.x = abs(star_container.scale.x)
	elif Player.last_direction.x == -1:
		star_container.position.x = abs(star_container.position.x)
		star_container.scale.x = -abs(star_container.scale.x)
