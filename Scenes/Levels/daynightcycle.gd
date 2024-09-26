extends CanvasModulate

const MINUTES_PER_DAY = 1440
const  MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE = (2 * PI) / MINUTES_PER_DAY

signal time_tick(day:int, hour:int, minute:int)
signal sun_kill()

var time:float = 0.0
var past_minute:float = -1.0
var playerSafe:bool = false
var returning = true

@onready var level_animation = $"../../LevelAnimation"


@export var gradient:GradientTexture1D
@export var INGAME_SPEED = 100
@export var INITIAL_HOUR = 1:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE * INITIAL_HOUR * MINUTES_PER_HOUR

func _ready():
	time = INGAME_TO_REAL_MINUTE * INITIAL_HOUR * MINUTES_PER_HOUR
	Events.player_safe.connect(_set_playerSafe)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * INGAME_TO_REAL_MINUTE * INGAME_SPEED
	var value = (sin(time - PI/2) + 1.0) / 2.0
	print(value)
	
	if(value>=0.4) and !level_animation.is_playing() and !returning:
		level_animation.play("flashing")
	if (value>=0.7) and level_animation.is_playing():
		level_animation.play("red_flashing")
	if (value >= 0.9999 and level_animation.is_playing()):
		level_animation.play("RESET")
		returning = true
	
	
	if value<0.4:
		returning = false
	
	if(value >= 0.999) and !playerSafe:
		sun_kill.emit()
	self.color = gradient.gradient.sample(value)
	_recalculate_time()

func _set_playerSafe(value):
	playerSafe = value
	print("Player safe: "+ str(playerSafe))

func _recalculate_time():
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE)
	var day = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	#print(int(hour))
	if past_minute != minute:
		time_tick.emit(day,hour,minute)
	
