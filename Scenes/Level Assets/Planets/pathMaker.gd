@tool
extends Path2D

const SIZE = 100
const NUM_POINTS = 32


func _ready() -> void:
	if Engine.is_editor_hint():
		curve = Curve2D.new()
		for i in NUM_POINTS:
			curve.add_point(Vector2(0, -SIZE).rotated((i / float(NUM_POINTS)) * TAU))

		# End the circle.
		curve.add_point(Vector2(0, -SIZE))
