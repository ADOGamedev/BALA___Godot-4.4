extends Control

@onready var LOCKED_NODE = $locked
@onready var LOCKED_LABEL = $locked/locked_label
@onready var UNLOCKED_NODE = $unlocked
@onready var DIAMONDS_INDICATOR = $unlocked/diamonds_indicator
@onready var DIAMONDS_PANEL = DIAMONDS_INDICATOR.get_node("VBoxContainer/PanelContainer")

@onready var level_box_themes = {
	"panel" : {
		"unlocked" : UNLOCKED_NODE.get_theme_stylebox("normal", "Button"),
		"locked" : LOCKED_NODE.get_theme_stylebox("panel", "PanelContainer")},
	"label_outline_color" : {
		"unlocked" : UNLOCKED_NODE.get_theme_color("font_outline_color", "Button"),
		"locked" : LOCKED_LABEL.get_theme_color("font_outline_color", "Label")},
	"label_font" : {
		"unlocked" : UNLOCKED_NODE.get_theme_font("font", "Button"),
		"locked" : LOCKED_LABEL.get_theme_font("font", "Label")},
	"diamonds_panel" : DIAMONDS_INDICATOR.get_node("VBoxContainer/PanelContainer").get_theme_stylebox("panel", "PanelContainer")
}

@export var level_num = 1:
	set = set_level
@export var is_locked = false:
	set = set_locked

var MODULATE_WHITE = 0xffffffff
var MODULATE_TRANSPARENT = 0xffffff00
var BUTTON_NORMAL_COLOR = 0x4a944fff
var BUTTON_HOVERED_COLOR = 0x57ad5cff
var BUTTON_PRESSED_COLOR = 0x6edb75ff

func _ready() -> void:
	set_theme_overrides()

	DIAMONDS_INDICATOR.modulate = Color.hex(MODULATE_TRANSPARENT)
	if level_num <= SaveLoadPlayerStats.player_stats["levels_unlocked"]:
		set_locked(false)
		DIAMONDS_INDICATOR.modulate = Color.hex(MODULATE_WHITE)

	LOCKED_NODE.visible = is_locked
	UNLOCKED_NODE.visible = !is_locked

func _process(_delta: float) -> void:
	level_box_themes["label_outline_color"]["locked"] = LOCKED_LABEL.get_theme_color("font_outline_color", "Label")
	LOCKED_NODE.visible = is_locked
	UNLOCKED_NODE.visible = !is_locked

func set_theme_overrides():
	var new_locked_panel = level_box_themes["panel"]["locked"].duplicate()
	LOCKED_NODE.add_theme_stylebox_override("panel", new_locked_panel)
	level_box_themes["panel"]["locked"] = LOCKED_NODE.get_theme_stylebox("panel", "PanelContainer")

	var new_unlocked_panel = level_box_themes["panel"]["unlocked"].duplicate()
	UNLOCKED_NODE.add_theme_stylebox_override("normal", new_unlocked_panel)
	level_box_themes["panel"]["unlocked"] = UNLOCKED_NODE.get_theme_stylebox("normal", "Button")
	
	var new_unlocked_font = level_box_themes["label_font"]["unlocked"].duplicate()
	UNLOCKED_NODE.add_theme_font_override("font", new_unlocked_font)
	level_box_themes["label_font"]["unlocked"]= UNLOCKED_NODE.get_theme_font("font", "Button")

	var new_locked_font = level_box_themes["label_font"]["locked"].duplicate()
	LOCKED_LABEL.add_theme_font_override("font", new_locked_font)
	level_box_themes["label_font"]["locked"] = LOCKED_LABEL.get_theme_font("font", "Label")

	var new_diamonds_panel = level_box_themes["diamonds_panel"].duplicate()
	DIAMONDS_PANEL.add_theme_stylebox_override("panel", new_diamonds_panel)
	level_box_themes["diamonds_panel"] = DIAMONDS_PANEL.get_theme_stylebox("panel", "PanelContainer")

func set_locked(value: bool):
	is_locked = value

func set_level(value: int):
	level_num = value
	if !is_inside_tree():
		await ready
	UNLOCKED_NODE.text = str(level_num)
	LOCKED_LABEL.text = str(level_num)

func unlock():
	expands_margins_tween(30, 0.05)
	await change_color_tween()
	await expands_margins_tween(20, 0.1)
	appear_diamonds_tween()
	set_locked(false)
	SaveLoadPlayerStats.player_stats["levels_unlocked"] = level_num
	SaveLoadPlayerStats.save_player_stats()

func expands_margins_tween(value: int, duration: float):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_parallel(true).set_loops(1)
	tween.tween_property(level_box_themes["panel"]["locked"], "expand_margin_bottom", value, duration)
	tween.tween_property(level_box_themes["panel"]["locked"], "expand_margin_left", value, duration)
	tween.tween_property(level_box_themes["panel"]["locked"], "expand_margin_top", value, duration)
	tween.tween_property(level_box_themes["panel"]["locked"], "expand_margin_right", value, duration)
	tween.tween_property(level_box_themes["label_font"]["locked"], "baseline_offset", level_box_themes["label_font"]["unlocked"].baseline_offset, duration)
	await tween.finished

func appear_diamonds_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_parallel(true).set_loops(1)
	tween.tween_property(DIAMONDS_INDICATOR, "modulate", Color.hex(MODULATE_WHITE), 0.2)
	await tween.finished

func change_color_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN).set_parallel(true).set_loops(1)
	tween.tween_property(level_box_themes["panel"]["locked"], "bg_color", level_box_themes["panel"]["unlocked"].bg_color, 0.1)
	tween.tween_property(level_box_themes["panel"]["locked"], "border_color", level_box_themes["panel"]["unlocked"].border_color, 0.1)
	tween.tween_method(unlock_lerp_font_outline, level_box_themes["label_outline_color"]["locked"], level_box_themes["label_outline_color"]["unlocked"], 0.1)
	await tween.finished

func _on_unlocked_mouse_entered() -> void:
	level_box_themes["diamonds_panel"].bg_color = Color.hex(BUTTON_HOVERED_COLOR)

func _on_unlocked_mouse_exited() -> void:
	level_box_themes["diamonds_panel"].bg_color = Color.hex(BUTTON_NORMAL_COLOR)

func unlock_lerp_font_outline(locked_color):
	LOCKED_LABEL.add_theme_color_override("font_outline_color", locked_color)

#! +--------------------------------------------------------------------------+
#! 							/!\ VERY IMPORTANT /!\
#!  Remember that the name of all levels has to be "level_" and the number of
#! 						level. If not, then it won't work
#! +--------------------------------------------------------------------------+
func _on_unlocked_pressed() -> void:
	JsonLootSavingLoading.set_obtained_loot_file_name(level_num)
	JsonLootSavingLoading.load_player_loot()
	GlobalSceneChange.change_scene = "res://level_" + str(level_num) + ".tscn"
	get_tree().call_deferred("change_scene_to_file", "res://loading_screen.tscn")

func _on_unlocked_button_down() -> void:
	level_box_themes["diamonds_panel"].bg_color = Color.hex(BUTTON_PRESSED_COLOR)
