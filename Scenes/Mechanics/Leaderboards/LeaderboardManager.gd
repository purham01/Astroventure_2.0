extends Node

var ghost_data_id_to_load = ""
var player_ghost_name = ""

func submit_score(leaderboard_id : String , time : float):
	var timebasedScore : int = time * 1;
	var response = await LL_Leaderboards.SubmitScore.new(leaderboard_id, timebasedScore, Save.player_UID).send()
	if(!response.success) :
		print("Submit failed")
		pass
	else:
		print("Submit success")
		Events.score_submitted.emit()
		pass

func get_leaderboard(leaderboard_id : String, count : int):
	var response = await LL_Leaderboards.GetScoreList.new(leaderboard_id, count).send()
	if(!response.success) :
		print("Request failed")
		return null
	else:
		print("Request success")
		return response

func set_player_name(new_name : String):
	var response = await LL_Players.SetPlayerName.new(new_name).send()
	if(!response.success) :
		print("Request failed", response)
		return null
	else:
		#print("Request success", response)
		return response

func get_player_name():
	var response = await LL_Players.GetPlayersActiveName.new().send()
	if(!response.success) :
		print("Request failed", response)
		return null
	else:
		print("Request success", response)
		return response

func fetch_ghost_data(player_UID : String, level_codename : String):
	var path = "user://GhostData/"+ level_codename + "/ghost_data_" + level_codename + "_" + player_UID + ".dat"
	var firebase_path = "GhostData/"+level_codename+ "/"+"ghost_data_" + level_codename + "_" + player_UID + ".dat"
	#download_ghost_data(player_UID, level_codename, path)
	
	get_tree().paused = false
	var result = await Firebase.Storage.ref(firebase_path).get_metadata()
	print(result)
	
	if !result:
		print("Cant connect to firebase")
		if FileAccess.file_exists(path):
			print("Ghost data found, restarting level")
			get_tree().reload_current_scene()
		else:
			print("Cant find ghost data and unable to download")
			return

	if FileAccess.file_exists(path):
		var modified_time = FileAccess.get_modified_time(path)
		var modified_time_firebase = result.get("updated")

		
		modified_time_firebase = modified_time_firebase.split(".")
		modified_time_firebase = Time.get_unix_time_from_datetime_string(modified_time_firebase[0])
		
		print("Last modified time: ",modified_time)
		print("Last modified time firebase: ",modified_time_firebase)
		
		if modified_time < modified_time_firebase:
			download_ghost_data(path, firebase_path)
			return
		
		print("Ghost data found, restarting level")
		get_tree().reload_current_scene()
	else:
		download_ghost_data(path, firebase_path)
		
	
	
func download_ghost_data(path, firebase_path):
	print("Dowloading ghost data")
	print(firebase_path)
	
	
	var result = await Firebase.Storage.ref(firebase_path).get_download_url()

	
	print("Firebase request result: ", result)
	if !result:
		print("Cant connect to firebase")
		return

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_http_request_completed)
	http.set_download_file(path)
	var request = http.request(result)
	if request != OK:
		push_error("Http request error")

func _http_request_completed(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	else:
		print("Download successful")
		get_tree().reload_current_scene()
	
