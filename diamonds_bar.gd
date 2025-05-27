extends Control

@onready var FULL_DIAMOND = preload("res://assets/ui/hud_diamond.png")
@onready var EMPTY_DIAMOND = preload("res://assets/ui/hud_diamond_empty.png")
@onready var FULL_DIAMOND_ROUND = preload("res://assets/ui/hud_diamond_rounded.png")
@onready var EMPTY_DIAMOND_ROUND = preload("res://assets/ui/hud_diamond_empty_rounded.png")
@onready var DIAMONDS = $diamonds.get_children()
@onready var TWEEN_DIAMONDS_ARRAY = [%tween_diamond1, %tween_diamond2, %tween_diamond3]
var total_diamonds: int
var diamonds_bool: Array
var diamonds_tweened = [false, false, false]
var is_onready = true

func _ready() -> void:
	for diamond in TWEEN_DIAMONDS_ARRAY:
		diamond.visible = false
		diamond.pivot_offset = diamond.size / Vector2(2, 2)

	update_diamonds()
	for i in range(3 - diamonds_bool.size()):
		diamonds_tweened.remove_at(0)

	for i in range(DIAMONDS.size() - total_diamonds):
		update_total_diamonds()
	

func _process(_delta: float) -> void:
	update_diamonds()
	is_onready = false

#? I have no idea of how this two functions make the diamonds work,
#? but rule #1: if something works, don`t touch it.
func update_diamonds():
	update_diamonds_bool()
	for diamonds_index in range(total_diamonds):
		var diamond = DIAMONDS[diamonds_index]
		var use_rounded_texture = false if (owner.name == "ui" or owner.name == "level_completed_screen") else true
		
		if diamond.texture == null:
			return
		if diamonds_bool[diamonds_index]:
			if is_onready:
				diamond.texture = FULL_DIAMOND if !use_rounded_texture else FULL_DIAMOND_ROUND

			if owner.name == "level_completed_screen":
				if !owner.visible:
					return
				await get_tree().create_timer(0.4).timeout

			if !use_rounded_texture and !diamonds_tweened[diamonds_index]:
				diamonds_tweened[diamonds_index] = true
				if diamond.texture != FULL_DIAMOND:
					tween_diamond_icon(diamonds_index)
				
			diamond.texture = diamond.texture if !use_rounded_texture else FULL_DIAMOND_ROUND

		else:
			diamond.texture = EMPTY_DIAMOND if !use_rounded_texture else EMPTY_DIAMOND_ROUND

func update_total_diamonds():
	for diamond_index in range(DIAMONDS.size()):
		if diamond_index <= DIAMONDS.size() - 1 - total_diamonds:
			if owner.name == "ui":
				DIAMONDS[diamond_index].texture = null
			else:
				DIAMONDS[diamond_index].visible = false
			DIAMONDS.remove_at(diamond_index)
			TWEEN_DIAMONDS_ARRAY.remove_at(diamond_index)

func update_diamonds_bool():
	if owner.is_in_group("level_boxes"):
		diamonds_bool = SaveLoadPlayerStats.player_stats["diamonds"][str(owner.level_num)]
	else:
		diamonds_bool = SaveLoadPlayerStats.player_stats["diamonds"][str(owner.owner.level_num)]
	total_diamonds = diamonds_bool.size()

func tween_diamond_icon(diamond_index: int):
	var diamond = TWEEN_DIAMONDS_ARRAY[diamond_index]
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false)
	if !is_onready:
		diamond.visible = true
		diamond.get_parent().texture = null
		tween.tween_property(diamond, "scale", Vector2(1.3, 1.3), 0.2)
		tween.tween_property(diamond, "scale", Vector2(0.8, 0.8), 0.1)
		tween.tween_property(diamond, "scale", Vector2.ONE, 0.1)
		await tween.finished
	diamond.get_parent().texture = FULL_DIAMOND
	diamond.queue_free()
	
