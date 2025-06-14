extends Area3D

var my_id = ""

var item_in_chest = false

@export var add_new_heart := true

func _ready() -> void:
	my_id = name
	if !item_in_chest:
		await owner.ready
		if JsonLootSavingLoading.player_loot.has(my_id):
			if JsonLootSavingLoading.player_loot[my_id] == false:
				queue_free()
				
	if add_new_heart:
		%heart2.visible = true

func _on_heart_body_entered(body):
	if item_in_chest:
		return
	if body.is_in_group("player"):
		$AnimationPlayer.play("dissapear")

		if add_new_heart:
			JsonLootSavingLoading.set_value(my_id, false)
			SaveLoadPlayerStats.player_stats["health"] += 2
			SaveLoadPlayerStats.player_stats["max_health"] += 2

			body.max_health += 2
			owner.get_node("ui").tween_heart_icon()
		body.health = body.max_health
		owner.get_node("ui").update_stats()

		await get_tree().create_timer(0.4).timeout
		queue_free()
