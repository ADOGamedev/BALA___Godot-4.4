extends Control

@onready var COINS_LABEL = $coins/coins_label
@onready var COINS_ICON = %coins_icon
@onready var LAST_HEART = %last_heart
@onready var VIGNETE = $vignete

@onready var FULL_HEART = preload("res://assets/ui/hud_heartFull.png")
@onready var HALF_HEART = preload("res://assets/ui/hud_heartHalf.png")
@onready var EMPTY_HEART = preload("res://assets/ui/hud_heartEmpty.png")

@onready var total_hearts = $all_hearts/upper_hearts_row.get_children() + $all_hearts/lower_hearts_row.get_children()
var max_health : int
var last_heart_beating = false
var last_heart_tween : Tween
var vignete_tween : Tween

func _ready() -> void:
	COINS_ICON.pivot_offset = COINS_ICON.size / Vector2(2, 2)
	LAST_HEART.pivot_offset = LAST_HEART.size / Vector2(2, 2)
	VIGNETE.material.set_shader_parameter("vignete_scale", 0.0)
	update_stats()

func _process(_delta: float) -> void:
	update_stats()

func update_stats():
	var player = owner.get_node("player")
	if player == null:
		return
	max_health = player.max_health
	update_hearts(player.health, max_health)
	update_coins_label()

func update_hearts(health: int, maximum_health: int):
	if health <= 2 and !last_heart_beating:
		tween_last_heart()
		tween_vignete()
		VIGNETE.visible = true
		last_heart_beating = true
	if health > 2 and last_heart_beating:
		last_heart_tween.stop()
		vignete_tween.stop()
		VIGNETE.visible = false
		last_heart_beating = false

	for heart_index in range(total_hearts.size()):
		var heart = total_hearts[heart_index]
		if heart is not TextureRect:
			heart = heart.get_child(0)
		heart.visible = maximum_health >= (heart_index + 1) * 2
		heart.texture = (
			FULL_HEART if health > heart_index * 2 + 1 else
			HALF_HEART if health > heart_index * 2 else
			EMPTY_HEART
		)

func update_coins_label():
	COINS_LABEL.text = str(owner.obtained_coins)

func tween_coins_icon():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false)
	tween.tween_property(COINS_ICON, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(COINS_ICON, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(COINS_ICON, "scale", Vector2.ONE, 0.1)

func tween_last_heart():
	last_heart_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops().set_parallel(false)
	last_heart_tween.tween_property(LAST_HEART, "scale", Vector2(1.0, 1.0), 0.0)
	last_heart_tween.tween_property(LAST_HEART, "scale", Vector2(1.15, 1.15), 0.3)
	last_heart_tween.tween_property(LAST_HEART, "scale", Vector2(0.8, 0.8), 0.15)
	last_heart_tween.tween_property(LAST_HEART, "scale", Vector2.ONE, 0.15)
	last_heart_tween.tween_property(LAST_HEART, "scale", Vector2(0.8, 0.8), 0.15)
	last_heart_tween.tween_property(LAST_HEART, "scale", Vector2.ONE, 0.15)
	last_heart_tween.play()

func tween_heart_icon():
	var first_heart = total_hearts[(max_health / 2.0) - 1.0].get_child(0)
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false)
	tween.tween_property(first_heart, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(first_heart, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(first_heart, "scale", Vector2.ONE, 0.1)

func tween_vignete():
	var shader_material = VIGNETE.material
	vignete_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops().set_parallel(false)
	vignete_tween.tween_method(func(value): shader_material.set_shader_parameter("vignete_scale", value), 1.1, 1.25, 0.3)
	vignete_tween.tween_method(func(value): shader_material.set_shader_parameter("vignete_scale", value), 1.25, 0.85, 0.15)
	vignete_tween.tween_method(func(value): shader_material.set_shader_parameter("vignete_scale", value), 0.85, 1.1, 0.15)
	vignete_tween.tween_method(func(value): shader_material.set_shader_parameter("vignete_scale", value), 1.1, 0.85, 0.15)
	vignete_tween.tween_method(func(value): shader_material.set_shader_parameter("vignete_scale", value), 0.85, 1.1, 0.15)
	vignete_tween.play()

func tween_damage_vignete():
	VIGNETE.visible = true
	var shader_material = VIGNETE.material
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops(1).set_parallel(false)
	tween.tween_method(func(value): shader_material.set_shader_parameter("vignete_scale", value), 1.1, 1.25, 0.3)
	tween.tween_method(func(value): shader_material.set_shader_parameter("vignete_scale", value), 1.25, 0.85, 0.15)
	tween.tween_method(func(value): shader_material.set_shader_parameter("vignete_scale", value), 0.85, 0.0, 0.2)
	
