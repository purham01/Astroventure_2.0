extends Node2D

@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var canvas_modulate = $CanvasLayer/CanvasModulate


# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
