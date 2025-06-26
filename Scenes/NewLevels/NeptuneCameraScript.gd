extends Node2D

#var scale_values = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
var scale_values = [0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5]

func _ready() -> void:
	Events.connect("change_gravity", change_gravity)
	
func change_gravity(new_rotation_degrees):
	return
	var i = 0
	if (new_rotation_degrees == 0 or new_rotation_degrees == 180):
		for c in get_children():
			if c is Parallax2D:
				c.scroll_scale.x = scale_values[i]
				c.scroll_scale.y = 0.0
				i+=1
	else:
		for c in get_children():
			if c is Parallax2D:
				c.scroll_scale.x = 0.0
				c.scroll_scale.y = scale_values[i]
				i+=1
	#if (new_rotation_degrees == 0 or new_rotation_degrees == 180):
		#for c : Parallax2D in get_children():
			#var scroll_scale_x_temp = c.scroll_scale.x
			#c.scroll_scale.x = c.scroll_scale.y
			#c.scroll_scale.y = scroll_scale_x_temp
		#var tween = get_tree().create_tween()
		#
		#if new_rotation_degrees == 0 and c.rotation_degrees == 270:
			#new_rotation_degrees = 360
		#elif abs(c.rotation_degrees - new_rotation_degrees) > 180:
			#new_rotation_degrees = new_rotation_degrees - 360

		
		#tween.tween_property(c, "rotation_degrees", new_rotation_degrees, CameraShake.camera_transition_duration)
		#if c.rotation_degrees == -360 or c.rotation_degrees == 360:
			#c.rotation_degrees = 0
	#for c in get_children():
		#if c.rotation_degrees == -360 or c.rotation_degrees == 360:
			#c.rotation_degrees = 0
