extends Node2D

@onready var mercury_path_follow_2d = $MercuryPath/MercuryPathFollow2D
@onready var venus_path_follow_2d = $VenusPath/VenusPathFollow2D
@onready var earth_path_follow_2d = $EarthPath/EarthPathFollow2D
@onready var mars_path_follow_2d = $MarsPath/MarsPathFollow2D
@onready var jupiter_path_follow_2d = $JupiterPath2D/JupiterPathFollow2D
@onready var saturn_path_follow_2d = $SaturnPath2D/SaturnPathFollow2D
@onready var uranus_path_follow_2d = $UranusPath2D/UranusPathFollow2D
@onready var neptune_path_follow_2d = $NeptunePath2D/NeptunePathFollow2D


@onready var path_array = [mercury_path_follow_2d,venus_path_follow_2d,
earth_path_follow_2d,mars_path_follow_2d, 
jupiter_path_follow_2d,saturn_path_follow_2d,uranus_path_follow_2d,neptune_path_follow_2d]

@onready var ship = $Ship
@onready var mercury = $MercuryPath/MercuryPathFollow2D/Mercury
@onready var venus = $VenusPath/VenusPathFollow2D/Venus
@onready var earth = $EarthPath/EarthPathFollow2D/Earth
@onready var mars = $MarsPath/MarsPathFollow2D/Mars
@onready var jupiter = $JupiterPath2D/JupiterPathFollow2D/Jupiter
@onready var saturn = $SaturnPath2D/SaturnPathFollow2D/Saturn


@onready var mercury_label = $PlanetLabels/MercuryLabel
@onready var earth_label = $PlanetLabels/EarthLabel
@onready var venus_label = $PlanetLabels/VenusLabel
@onready var mars_label = $PlanetLabels/MarsLabel
@onready var jupiter_label = $PlanetLabels/JupiterLabel
@onready var saturn_label = $PlanetLabels/SaturnLabel
@onready var uranus_label = $PlanetLabels/UranusLabel
@onready var neptune_label = $PlanetLabels/NeptuneLabel

@onready var mercury_marker = $MercuryPath/MercuryPathFollow2D/MercuryMarker
@onready var venus_marker = $VenusPath/VenusPathFollow2D/VenusMarker
@onready var earth_marker = $EarthPath/EarthPathFollow2D/EarthMarker
@onready var mars_marker = $MarsPath/MarsPathFollow2D/MarsMarker
@onready var jupiter_marker = $JupiterPath2D/JupiterPathFollow2D/JupiterMarker
@onready var saturn_marker = $SaturnPath2D/SaturnPathFollow2D/SaturnMarker
@onready var uranus_marker = $UranusPath2D/UranusPathFollow2D/UranusMarker
@onready var neptune_marker = $NeptunePath2D/NeptunePathFollow2D/NeptuneMarker



var rng = RandomNumberGenerator.new()

func _ready():
	
	for path in path_array:
		path.progress_ratio = rng.randf()
	get_tree().paused = false
	await LevelTransition.fade_from_black()
	
	#ship.global_position = earth.global_position

func _process(delta):
	mercury_label.global_position = mercury_marker.global_position
	venus_label.global_position = venus_marker.global_position
	earth_label.global_position = earth_marker.global_position
	mars_label.global_position = mars_marker.global_position
	jupiter_label.global_position = jupiter_marker.global_position
	saturn_label.global_position = saturn_marker.global_position
	uranus_label.global_position = uranus_marker.global_position
	neptune_label.global_position = neptune_marker.global_position
