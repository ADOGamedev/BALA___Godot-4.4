extends Control

@onready var EXIT_CONFIRMATION_NODE = $all_elements/death_screen/exit_confirmation
@onready var FADE_IN = $fade_in

func _on_restart_pressed() -> void:
	restart()

func _on_leave_button_down() -> void:
	EXIT_CONFIRMATION_NODE.is_in_exit_confirmation = true
	EXIT_CONFIRMATION_NODE.shacky_effect()
	EXIT_CONFIRMATION_NODE.visible = true

func restart():
	if check_exit_confirmation():
		return
	get_tree().reload_current_scene()

func check_exit_confirmation():
	if EXIT_CONFIRMATION_NODE.is_in_exit_confirmation:
		EXIT_CONFIRMATION_NODE.shacky_effect()
		return true
	return false

func show_death_screen():
	visible = true
	await fade(1.0)
	$all_elements.visible = true
	await fade(0.0)
	FADE_IN.queue_free()

func fade(fade_to: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(FADE_IN, "modulate", Color(0.0, 0.0, 0.0, fade_to), 0.6)
	await tween.finished
