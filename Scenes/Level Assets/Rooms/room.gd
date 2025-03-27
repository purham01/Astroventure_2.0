extends Area2D

@export var kill_floor = true
@onready var kill_floor_col_shape: CollisionShape2D = $DeathZones/HazardArea/CollisionShape2D
var entrance_from_below = false
@export var entrance_from_below_toggle = true
@onready var check_from_below_col_shape: CollisionShape2D = $CheckIfFromBelow/CollisionShape2D

func _ready() -> void:
	
	if !kill_floor:
		kill_floor_col_shape.set_deferred("disabled", true)
	
	if !entrance_from_below_toggle:
		check_from_below_col_shape.set_deferred("disabled", true)
	


func _on_check_if_from_below_body_entered(body: Node2D) -> void:
	entrance_from_below = true


func _on_check_if_from_below_area_entered(area: Area2D) -> void:
	entrance_from_below = true
