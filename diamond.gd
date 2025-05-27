extends Area3D

var my_id = ""

@export var item_in_chest = false
@export var number_of_diamond = 1
@export var show_blue_light = false

func _ready() -> void:
	my_id = name
	if !item_in_chest:
		await owner.ready
	if JsonLootSavingLoading.player_loot.has(my_id):
		if JsonLootSavingLoading.player_loot[my_id] == false:
			queue_free()
	
	$meshes/OmniLight3D.visible = true if item_in_chest else false
	$blue_light.visible = true if show_blue_light else false
				
func _on_body_entered(body: Node3D) -> void:
	if item_in_chest:
		return
	if body.is_in_group("player"):
		$AnimationPlayer.play("dissapear")
		body.SFX_DIAMOND.play()

		SaveLoadPlayerStats.player_stats["total_diamonds"] += 1
		SaveLoadPlayerStats.player_stats["diamonds"][str(owner.level_num)][number_of_diamond - 1] = true
		JsonLootSavingLoading.set_value(my_id, false)
		SaveLoadPlayerStats.player_stats["diamonds"][str(owner.level_num)][number_of_diamond - 1] = true

		await get_tree().create_timer(0.4).timeout
		queue_free()
