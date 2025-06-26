extends Node

@export var level_codename : String 
@export var leaderboard_id: String:
	set(id):
		leaderboard_id = id
		score_offset = 0
		#refresh_scores()

## The offset from the first high score
@export var score_offset := 0
## Fetch up to a maximum of this many scores.
@export_range(1, 50) var count := 50

## The color to highlight the current player's scores.
@export var current_player_highlight_color := Color("#005216")

@onready var score_list := %ScoreList

@export var disabled = false
@export var dont_accept_input = false
@onready var race_info: RichTextLabel = $PanelContainer/VBoxContainer/RaceInfo

var selected :TreeItem

func _ready() -> void:
	#Events.connect("score_submitted",refresh_scores)
	Events.enable_leaderboard_ghosts.connect(enable_leaderboard_ghosts)
	score_list.set_column_expand_ratio(1, 3)
	var column_names := ["Rank", "Name", "Time"]
	for column_index in range(column_names.size()):
		var cname: String = column_names[column_index]
		score_list.set_column_title(column_index, cname)
		score_list.set_column_title_alignment(column_index, HORIZONTAL_ALIGNMENT_LEFT)
		column_index += 1
	if leaderboard_id:
		if Save.player_UID == "":
			await Events.player_logged_in
		refresh_scores()

func refresh_scores():
	score_list.clear()
	var root: TreeItem = score_list.create_item()
	var score_data 
	score_data = await LeaderboardManager.get_leaderboard(leaderboard_id, count)
	#print(score_data)
	
	if score_data != null:
		
		if score_data.items.size() > 0: 
			for score in score_data.items:
				#print("Score: ", score.player.public_uid)
				var row: TreeItem = score_list.create_item(root)
				row.set_text(0, str(score.rank))
				
				if str(score.player.name) == "":
					row.set_text(1, str(score.player.public_uid))
				else:
					row.set_text(1, str(score.player.name))
				row.set_text(2, str(score.score/1000.0))
				#row.set_text(3, str(score.player.public_uid))
				row.set_metadata(1, str(score.player.public_uid))
				
				if score.player.public_uid == Save.player_UID:
					for i in range(3):
						row.set_custom_bg_color(i, current_player_highlight_color)
				score_list.scroll_to_item(row)
		else:
			var row: TreeItem = score_list.create_item(root)
			row.set_text(0, "No scores were found")
	else:
		var row: TreeItem = score_list.create_item(root)
		row.set_text(0, "There was an error fetching scores.")


	#next_button.disabled = not score_data["has_more_scores"]


#func _on_prev_button_pressed() -> void:
	#if score_offset > 0:
		#score_offset = max(0, score_offset - score_limit)
		#refresh_scores()
#
#
#func _on_next_button_pressed() -> void:
	#score_offset = score_offset + score_limit
	#refresh_scores()



func _input(event: InputEvent) -> void:
	if dont_accept_input:
		return
	if event.is_action_pressed("ui_accept") and !disabled:
		selected = score_list.get_selected()
		if selected != null:
			
			var player_UID = selected.get_metadata(1)
			print(player_UID)
			LeaderboardManager.player_ghost_name = selected.get_text(1)
			LeaderboardManager.ghost_data_id_to_load = player_UID
			LeaderboardManager.fetch_ghost_data(player_UID, level_codename)

func _on_score_list_focus_entered() -> void:
	disabled = false


func _on_score_list_focus_exited() -> void:
	selected == null
	disabled = true

func enable_leaderboard_ghosts():
	dont_accept_input = false
	race_info.show()
	
