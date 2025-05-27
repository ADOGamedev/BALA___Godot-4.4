extends Control

@onready var SAVE_INDICATOR = $save_indicator
@onready var DARK_PANEL = $Panel
@onready var ALL_ELEMENTS = $elements
@onready var COINS_LABEL = %coins_label

var MODULATE_WHITE = 0xffffffff
var MODULATE_TRANSPARENT = 0xffffff00

func _ready() -> void:
	DARK_PANEL.modulate = Color.hex(MODULATE_TRANSPARENT)

func appear():
	SAVE_INDICATOR.indicate_saving()
	visible = true
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_parallel(true)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(ALL_ELEMENTS, "position:y", 0.0, 0.7)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(DARK_PANEL, "modulate", Color.hex(MODULATE_WHITE), 0.7)
	await tween.finished

func show_obtained_coins():
	if int(COINS_LABEL.text) < owner.obtained_coins:
		await get_tree().create_timer(0.1).timeout
		COINS_LABEL.text = "+ " + str(int(COINS_LABEL.text) + 1)
		show_obtained_coins()
		
func _on_continue_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_selection.tscn")
