extends Control

@onready var EXIT_CONFIRMATION_NODE = $exit_confirmation
@onready var OPTIONS_MENU = $options_menu

func _ready() -> void:
	UpdateResolution.update_resolution()
		
func _on_play_pressed() -> void:
	if check_exit_confirmation():
		return
	get_tree().change_scene_to_file("res://level_selection.tscn")

func _on_exit_button_down() -> void:
	EXIT_CONFIRMATION_NODE.is_in_exit_confirmation = true
	EXIT_CONFIRMATION_NODE.shacky_effect()
	EXIT_CONFIRMATION_NODE.visible = true

func _on_options_pressed() -> void:
	if check_exit_confirmation():
		return
	OPTIONS_MENU.visible = true

func check_exit_confirmation():
	if EXIT_CONFIRMATION_NODE.is_in_exit_confirmation:
		EXIT_CONFIRMATION_NODE.shacky_effect()
		return true
	return false
