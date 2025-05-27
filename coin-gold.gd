extends Area3D

var my_id = ""

var item_in_chest = false

func _ready() -> void:
	my_id = name
	if !item_in_chest:
		await owner.ready
		if JsonLootSavingLoading.player_loot.has(my_id):
			if JsonLootSavingLoading.player_loot[my_id] == false:
				queue_free()

func _on_coingold_body_entered(body):
	if item_in_chest:
		return
	if body.is_in_group("player"):
		owner.get_node("ui").tween_coins_icon()
		$"coin-gold/AnimationPlayer".play("dissapear")
		body.SFX_COIN.play()

		JsonLootSavingLoading.set_value(my_id, false)
		SaveLoadPlayerStats.player_stats["total_coins"] += 1
		owner.obtained_coins += 1

		await get_tree().create_timer(0.4).timeout
		queue_free()
