extends Control

@onready var EXIT_CONFIRMATION_NODE = $exit_confirmation
@onready var PARENT_UI = owner.get_node("ui")
@onready var OPTIONS_MENU = $options_menu
var is_esc_just_released = false

func _process(_delta : float) -> void:
	if !visible:
		return
	if Input.is_action_just_released("ui_cancel"):
		is_esc_just_released = true

	if Input.is_action_pressed("ui_cancel") and is_esc_just_released:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_leave_button_down() -> void:
	EXIT_CONFIRMATION_NODE.is_in_exit_confirmation = true
	EXIT_CONFIRMATION_NODE.shacky_effect()
	EXIT_CONFIRMATION_NODE.visible = true

func _on_options_pressed() -> void:
	if check_exit_confirmation():
		return
	OPTIONS_MENU.visible = true

func resume():
	if check_exit_confirmation():
		return
	visible = false
	get_tree().paused = false
	PARENT_UI.visible = true
	OPTIONS_MENU.visible = false
	is_esc_just_released = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func check_exit_confirmation():
	if EXIT_CONFIRMATION_NODE.is_in_exit_confirmation:
		EXIT_CONFIRMATION_NODE.shacky_effect()
		return true
	return false
