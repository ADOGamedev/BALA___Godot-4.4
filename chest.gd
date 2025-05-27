extends StaticBody3D

var my_id = ""
var my_item_id = ""

@export var ITEM : PackedScene
@onready var LOCK = $lock
@onready var PLAYER = owner.get_node("player")

@export var locked = true
@export var number_of_items: int
@export var number_of_diamond: int
var player_in = false
var player_has_key = false
var opened = false
var can_unlock = false
@onready var items_left: int
@onready var item_scale_factor = 0.4 if (ITEM.instantiate().is_in_group("coins") or 
										ITEM.instantiate().is_in_group("hearts")) else 0.65

func _ready() -> void:
	items_left = number_of_items
	var item_instance = ITEM.instantiate()
	my_id = name
	my_item_id = "chest_" + item_instance.name

	await owner.ready
	if JsonLootSavingLoading.player_loot.has(my_id):
		if JsonLootSavingLoading.player_loot[my_id] == false:
			can_unlock = true
			locked = false
			opened = true
			$AnimationPlayer.play("open")
			JsonLootSavingLoading.player_loot[my_item_id] = false
	
func _process(_delta: float) -> void:
	if player_in and !locked and !opened:
		open()
	if LOCK != null:
		remove_lock()

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"): 
		player_in = true

func _on_area_3d_body_exited(body:Node3D) -> void:
	if body.is_in_group("player"): 
		player_in = false

func give_item(item_to_give):
	for i in range(number_of_items):
		var item_instance = item_to_give.instantiate()
		item_instance.item_in_chest = true
		item_instance.scale *= item_scale_factor
		add_child(item_instance)

		await animate_item(item_instance)
		
		if !owner.level_completed:
			if item_instance.is_in_group("coins"):
				SaveLoadPlayerStats.player_stats["total_coins"] += 1
				owner.obtained_coins += 1
				JsonLootSavingLoading.set_value(my_item_id, false)
				owner.get_node("ui").tween_coins_icon()
				PLAYER.SFX_COIN.play()
			if item_instance.is_in_group("diamonds"):
				SaveLoadPlayerStats.player_stats["total_diamonds"] += 1
				SaveLoadPlayerStats.player_stats["diamonds"][str(owner.level_num)][number_of_diamond - 1] = true
				JsonLootSavingLoading.set_value(my_item_id, false)
				PLAYER.SFX_DIAMOND.play()
			if item_instance.is_in_group("hearts"):
				JsonLootSavingLoading.set_value(my_id, false)
				SaveLoadPlayerStats.player_stats["health"] += 2
				SaveLoadPlayerStats.player_stats["max_health"] += 2

				PLAYER.max_health += 2
				PLAYER.health += PLAYER.max_health
				owner.get_node("ui").update_stats()
				owner.get_node("ui").tween_heart_icon()

		items_left -= 1
		
		item_instance.queue_free()

func open():
	owner.current_chest = self
	JsonLootSavingLoading.set_value(my_id, false)

	opened = true
	$AnimationPlayer.play("open")
	give_item(ITEM)

func remove_lock():
	if player_has_key and locked:
		can_unlock = true
	if can_unlock:
		unlock()

func unlock():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(LOCK, "rotation_degrees:x", 90, 0.8)
	locked = false
	can_unlock = false

func animate_item(item):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)
	var item_target_y_pos = 0.28 if ITEM.instantiate().is_in_group("coins") else 0.16
	var total_duration = 1.0/(number_of_items + 0.3) + 0.3 #* f(y) = 1/(x-0.3)-0.3
	tween.tween_property(item, "global_position:y", global_position.y + item_target_y_pos * scale.y, total_duration * 4/13)
	tween.tween_property(item, "global_position:y", global_position.y + (item_target_y_pos - 0.02) * scale.y, total_duration * 6/13)
	tween.tween_property(item, "scale", item.scale + Vector3(0.15, 0.15, 0.15), total_duration * 2/13)
	tween.tween_property(item, "scale", Vector3(0, 0, 0), total_duration * 1/13)
	await tween.finished
