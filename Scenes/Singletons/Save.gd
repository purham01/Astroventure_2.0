extends Node

@onready var save_file = null
const SAVE_FILE_PATH = "user://savegame.save"

var save_data = {
	"PlayerName" : "Player",
	"Earth": 0.0,
	"Mercury" : 0.0,
	"Venus" : 0.0,
	"Mars" : 0.0,
	"Jupiter" : 0.0,
	"Saturn" : 0.0,
	"Neptune" : 0.0,
	"Uranus" : 0.0
}

func _ready() -> void:
	save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ_WRITE)
	print("Loading save")
	
	if save_file == null:
		print("No save file found")
		save_game()
		return
	else:
		print("Save file found")
		load_game()
		print("Loaded save")
	
	print(save_data)
	print(save_data.get("PlayerName"))


func save_game():
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)


# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		print("Json string: ", json_string)
		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		print("Parse result: ", parse_result)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		save_data = json.data
