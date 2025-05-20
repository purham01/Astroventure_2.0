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

func _ready() -> void:
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
