extends Node

const SAVE_FILE_PATH = "user://savegame.save"
const ACCOUNT_FILE_PATH = "user://player_account.cfg"
@onready var config = ConfigFile.new()


var planet_data = {
	"BestTime" : 0.0,
	"Medal" : "",
	"Stars" : [],
	"LeftEyeCollected" : false,
	"LeftEyeInserted" : false,
	"RightEyeCollected" : false,
	"RightEyeInserted" : false,
}

var Earth_data = planet_data.duplicate()
var Mercury_data = planet_data.duplicate()
var Venus_data = planet_data.duplicate()
var Mars_data = planet_data.duplicate()
var Jupiter_data = planet_data.duplicate()
var Saturn_data = planet_data.duplicate()
var Neptune_data = planet_data.duplicate()
var Uranus_data = planet_data.duplicate()

var save_data = {
	"PlayerName" : "Player",
	"Earth": Earth_data,
	"Mercury" : Mercury_data,
	"Venus" : Venus_data,
	"Mars" : Mars_data,
	"Jupiter" : Jupiter_data,
	"Saturn" : Saturn_data,
	"Neptune" : Neptune_data,
	"Uranus" : Uranus_data
}

var save_data_default = {
	"PlayerName" : "Player",
	"Earth": Earth_data,
	"Mercury" : Mercury_data,
	"Venus" : Venus_data,
	"Mars" : Mars_data,
	"Jupiter" : Jupiter_data,
	"Saturn" : Saturn_data,
	"Neptune" : Neptune_data,
	"Uranus" : Uranus_data
}
var planet_data_array = [Earth_data, Mercury_data, Venus_data, Mars_data, Jupiter_data, Saturn_data, Neptune_data, Uranus_data]


var playerIdentifier : String = ""
var player_UID : String = ""

func _ready() -> void:
	var err = FileAccess.file_exists(SAVE_FILE_PATH)
	print("Loading save")
	
	if err == false:
		print("No save file found")
		#save_game()
		#return
	else:
		print("Save file found")
		load_game()
		login_account()
		print("Loaded save")
		#print("Save data: ", save_data)
	
	
	
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	
	Firebase.Auth.login_with_email_and_password("benjamin.zrakic@gmail.com","vanizmojemocvare")
	
	Events.loaded_save.emit()

func on_login_succeeded(auth):
	print("Firebase login succesful")
	#print(auth)
	Firebase.Auth.save_auth(auth)
	

func login_account():
	var err = config.load(ACCOUNT_FILE_PATH)
	print("Loading settings")
	
	if err != OK:
		print("Failed to load")
		create_new_player()
		return
	else:
		playerIdentifier = config.get_value("account", "player_id")
		var check = config.has_section_key("account","player_uid")
		if check:
			player_UID = config.get_value("account","player_uid")
		print("Loaded account")
	
	var guestLoginResponse = await LL_Authentication.GuestSession.new(playerIdentifier).send()
	if(!guestLoginResponse.success) :
		printerr("Guest login failed with reason: " + guestLoginResponse.error_data.to_string())
		Events.emit_signal("player_logged_in")
		return
	else:
		print("Logged into server with: ", str(guestLoginResponse.public_uid))
	

	var check = config.has_section_key("account","player_uid")
	if !check:
		config.set_value("account", "player_uid", str(guestLoginResponse.public_uid))
		
	config.save(ACCOUNT_FILE_PATH)
	
	
	
	print("Logged in player UID: ", player_UID)
	
	Events.emit_signal("player_logged_in")

func create_new_player():
	print("Setting new player ID")
	playerIdentifier = str(randi_range(1000000, 9999999))

	config.set_value("account", "player_id", str(playerIdentifier))
	
	var guestLoginResponse = await LL_Authentication.GuestSession.new(playerIdentifier).send()
	if(!guestLoginResponse.success) :
		printerr("Guest login failed with reason: " + guestLoginResponse.error_data.to_string())
		
	else:
		config.set_value("account", "player_uid", str(guestLoginResponse.public_uid))
		config.save(ACCOUNT_FILE_PATH)
	
		player_UID = guestLoginResponse.public_uid
	
		LeaderboardManager.set_player_name(save_data.PlayerName)
	
		print("Creating new player succesful")
		print(player_UID)
	
	Events.emit_signal("player_logged_in")
	
	

func new_game(player_name : String):
	save_data = save_data_default
	save_data.PlayerName = player_name
	save_game()
	create_new_player()
	
	await Events.player_logged_in
	print("Emitting new game created signal")
	Events.emit_signal("new_game_started")


func save_game():
	#print("Saving data: ", save_data)
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)
	
	#for data in planet_data_array:
		#json_string = JSON.stringify(data)
		#save_file.store_line(json_string)
	#
	save_file.close()
	
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	#var i = 0
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		#print("Json string: ", json_string)
		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		#print("Parse result: ", parse_result)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		#if i == 0:
		save_data = json.data
			#i+=1
		#else:
			#planet_data_array[i-1] = json.data
