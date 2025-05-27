extends Node

var obtained_loot_file := ConfigFile.new()
var obtained_loot_file_name = ""

func set_obtained_loot_file_name(number: int):
	obtained_loot_file_name = "user://level_" + str(number) + "_obtained_loot.cfg"
	if FileAccess.file_exists(obtained_loot_file_name):
		obtained_loot_file.load(obtained_loot_file_name)

func set_value(my_group: String, my_id: String, value):
	obtained_loot_file.set_value(my_group, my_id, value)

func save():
	obtained_loot_file.save(obtained_loot_file_name)

func load(my_group: String, my_id: String, value_to_check):
	if FileAccess.file_exists(obtained_loot_file_name):
		obtained_loot_file.load(obtained_loot_file_name)
		if obtained_loot_file.get_value(my_group, my_id) == value_to_check:
			return true

func set_all_loot(node: Node, number: int):
	obtained_loot_file_name = "user://level_" + str(number) + "_obtained_loot.cfg"
	obtained_loot_file.load(obtained_loot_file_name)
	if !FileAccess.file_exists(obtained_loot_file_name):
		for coin in node.get_tree().get_nodes_in_group("coins"):
			var coin_id = coin.name
			set_value("coins", coin_id, true)
		for chest in node.get_tree().get_nodes_in_group("chests"):
			if chest.ITEM.instantiate().is_in_group("coins"):
				var chest_coin_id = "chest_" + chest.ITEM.instantiate().name
				set_value("coins", chest_coin_id, true)

			elif chest.ITEM.instantiate().is_in_group("diamonds"):
				var chest_diamond_id = "chest_" + chest.ITEM.instantiate().name
				set_value("diamonds", chest_diamond_id, true)

			var chest_id = chest.name
			set_value("chests", chest_id, true)
		for diamond in node.get_tree().get_nodes_in_group("diamonds"):
			var diamond_id = diamond.name
			set_value("diamonds", diamond_id, true)
		for pickable_blaster in node.get_tree().get_nodes_in_group("pickable_blasters"):
			var pickable_blaster_id = pickable_blaster.name
			set_value("pickable_blasters", pickable_blaster_id, true)
	
	save()
