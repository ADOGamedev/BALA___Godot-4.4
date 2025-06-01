extends Node

var file_path = "user://player_stats.dat"

var player_stats = {
	"player_current_weapon": "",
	"player_available_weapons": [],
	"player_has_loaded_weapons": false,

	"levels_completed": 0,
	"levels_unlocked": 0,

	"diamonds": {
		"1": [false],
		"2": [false, false],
		"3": [false, false, false],
		"4": [false, false],
		"5": [false, false],
		"6": [false, false],
		"7": [false, false],
		"8": [false, false],
		"9": [false, false],
		"10": [false, false],
	},
	"total_coins": 0,
	"total_diamonds": 0,

	"max_health": 4,
	"health": 4
}

func save_player_stats():
	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	save_file.store_var(player_stats)
	save_file = null #* Is like closing the file

func load_player_stats():
	if FileAccess.file_exists(file_path):
		var save_file = FileAccess.open(file_path, FileAccess.READ)
		player_stats = save_file.get_var()
		save_file = null
