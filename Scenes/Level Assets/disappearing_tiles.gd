extends Node2D

@export var tile_left : Node = null
@export var tile_right : Node = null
@onready var activator_area_active = true

func _process(delta):
	if get_tree().get_root().get_node("World/Player").get("playerDead"):
		$CollisionArea.set_collision_layer_value(4, true)
		activator_area_active = true
		show()
		$Sprite2D.modulate.a = 1
	if $DisappearTimer.time_left:
		$Sprite2D.modulate.a = $DisappearTimer.time_left

func _on_disappear_timer_timeout():
	$CollisionArea.set_collision_layer_value(4, false)
	hide()

func _on_activator_area_area_entered(area):
	if activator_area_active:
		activator_area_active = false
		$DisappearTimer.start()
		if tile_right != null:
			tile_right._on_activator_area_area_entered(area)
		if tile_left != null:
			tile_left._on_activator_area_area_entered(area)
