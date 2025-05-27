extends Node

func _ready() -> void:
	SaveLoadPlayerStats.load_player_stats()
	if !FileAccess.file_exists(SaveLoadPlayerStats.file_path):
		SaveLoadPlayerStats.save_player_stats()
