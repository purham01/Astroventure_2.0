extends CanvasLayer

@onready var animation_player = $AnimationPlayer

func fade_from_black():
	animation_player.play("FadeFromBlack")
	await(animation_player.animation_finished)

func fade_to_black():
	animation_player.play("FadeToBlack")
	await(animation_player.animation_finished)

func fade_to_black_menu():
	animation_player.play("FadeToBlack_Menu")
	await(animation_player.animation_finished)
