extends Node3D

@export var tween_full_duration : float = 6.0
@export var can_move = false

var player_in = false

func _ready() -> void:
	if can_move:
		start_moving_tween()

func start_moving_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_loops().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property($Path3D/PathFollow3D, "progress_ratio", 1.0, tween_full_duration / 2)
	tween.tween_property($Path3D/PathFollow3D, "progress_ratio", 0.0, tween_full_duration / 2)

