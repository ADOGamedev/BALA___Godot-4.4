extends Control

@export var in_paused_menu: bool = false
@export var in_controls_menu: bool = false
@export var in_repeated_controls: bool = false
var is_in_exit_confirmation = false

func _process(_delta: float) -> void:
	pivot_offset = size / Vector2(2, 2)

func _on_exit_button_button_down():
	is_in_exit_confirmation = true
	if in_paused_menu:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://level_selection.tscn")
	elif in_repeated_controls:
		owner.get_node("VBoxContainer/MarginContainer/HBoxContainer/all_options/controls/VBoxContainer/controls_asign").change_controls = true
	elif in_controls_menu:
		owner.CONTROLS_ASIGN_NODE.asign_all_controls(owner.CONTROLS_ASIGN_NODE.default_controls)
	else:
		get_tree().quit()
	visible = false

func _on_cancel_button_button_down() -> void:
	is_in_exit_confirmation = false
	visible = false

func shacky_effect():
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "rotation_degrees", 3, 0.06)
	tween.tween_property(self, "rotation_degrees", 0, 0.06)
	tween.tween_property(self, "rotation_degrees", -3, 0.06)
	tween.tween_property(self, "rotation_degrees", 0, 0.06)
