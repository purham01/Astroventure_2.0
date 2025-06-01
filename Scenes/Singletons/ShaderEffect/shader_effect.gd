extends Node2D

@onready var crt: CanvasLayer = $CRT
@onready var chromatic: CanvasLayer = $Chromatic
@onready var grayscale: CanvasLayer = $Grayscale


func _ready() -> void:
	var general_settings = ConfigFileHandler.load_general_settings()
	change_shader_settings(general_settings.get("shader_setting"))

func change_shader_settings(index):
	match index:
		0: #none
			crt.hide()
			chromatic.hide()
			grayscale.hide()
		1: #CRT
			crt.show()
			chromatic.hide()
			grayscale.hide()
		2: #chromatic
			crt.hide()
			chromatic.show()
			grayscale.hide()
		3: #grayscale
			crt.hide()
			chromatic.hide()
			grayscale.show()
