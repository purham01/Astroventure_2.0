extends MarginContainer

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sprite_bright: Sprite2D = $SpriteBright
@onready var sprite_dark: Sprite2D = $SpriteDark
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func set_collected():
	sprite_bright.show()
	sprite_dark.hide()
	gpu_particles_2d.emitting = true
	timer.start(randf_range(0.0,1.0))


func _on_timer_timeout() -> void:
	animation_player.play("float")
