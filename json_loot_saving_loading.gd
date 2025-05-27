extends Node

var json_path = ""
var player_loot: Dictionary = { }

func set_obtained_loot_file_name(number: int):
	json_path = "user://level_" + str(number) + "_obtained_loot.json"
	if FileAccess.file_exists(json_path):
		pass

func save_player_loot():
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(player_loot))
	file.close()

func load_player_loot():
	var file = FileAccess.open(json_path, FileAccess.READ)
	if FileAccess.file_exists(json_path):
		player_loot = JSON.parse_string(file.get_as_text())
		file.close()

func set_value(key: String, value):
	player_loot[key] = value

func set_all_loot(node: Node, number: int):
	json_path = "user://level_" + str(number) + "_obtained_loot.json"
	player_loot = { }
	if !FileAccess.file_exists(json_path):
		for coin in node.get_tree().get_nodes_in_group("coins"):
			var coin_id = coin.name
			player_loot[coin_id] = true
		for chest in node.get_tree().get_nodes_in_group("chests"):
			if chest.ITEM.instantiate().is_in_group("coins"):
				var chest_coin_id = "chest_" + chest.ITEM.instantiate().name
				player_loot[chest_coin_id] = true

			elif chest.ITEM.instantiate().is_in_group("diamonds"):
				var chest_diamond_id = "chest_" + chest.ITEM.instantiate().name
				player_loot[chest_diamond_id] =  true

			elif chest.ITEM.instantiate().is_in_group("hearts"):
				var chest_heart_id = "chest_" + chest.ITEM.instantiate().name
				player_loot[chest_heart_id] =  true

			var chest_id = chest.name
			player_loot[chest_id] = true

		for diamond in node.get_tree().get_nodes_in_group("diamonds"):
			var diamond_id = diamond.name
			player_loot[diamond_id] = true

		for pickable_blaster in node.get_tree().get_nodes_in_group("pickable_blasters"):
			var pickable_blaster_id = pickable_blaster.name
			player_loot[pickable_blaster_id] = true

		for heart in node.get_tree().get_nodes_in_group("hearts"):
			var heart_id = heart.name
			player_loot[heart_id] = true
	
		save_player_loot()

	else:
		load_player_loot()
