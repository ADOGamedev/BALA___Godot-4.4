extends Node3D

signal tween_finished

@onready var PATH_FOLLOW = $Path3D/PathFollow3D
@export var move_when_player_on_top = false
@export var one_travel = false
@export var tween_trans: int = 1 

@onready var FRONT_RAY = $CharacterBody3D/front_ray
@onready var BACK_RAY = $CharacterBody3D/back_ray

var can_move = false
var tweening = false
var tween: Tween
var ray_colliding

@export var tween_full_duration : float = 6.0

func _process(_delta: float) -> void:
	if !move_when_player_on_top:
		can_move = true
	if PATH_FOLLOW.progress_ratio == 0 or PATH_FOLLOW.progress_ratio == 1:
		if name == "moving_plat_final":
			emit_signal("tween_finished")
	move_platform()

func move_platform():
	if FRONT_RAY.is_colliding():
		ray_colliding = FRONT_RAY
	if BACK_RAY.is_colliding():
		ray_colliding = BACK_RAY
	if ray_colliding != null:
		if ray_colliding.get_collider() != null:
			if ray_colliding.get_collider().is_in_group("player"):
				if !ray_colliding.get_collider().is_on_floor():
					ray_colliding.get_collider().position.y -= 0.1
		
	if can_move and !tweening:
		tween = get_tree().create_tween().set_trans(tween_trans).set_parallel(false)
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tweening = true

		if one_travel:
			tween.set_loops(1)
		else:
			tween.set_loops()

		if PATH_FOLLOW.progress_ratio == 0 or PATH_FOLLOW.progress_ratio == 1:
			var target_ratio = 1 - PATH_FOLLOW.progress_ratio
			animate_tween_to(target_ratio)
			if !one_travel:
				animate_tween_to(1 - target_ratio)

	elif !can_move and tweening:
		tweening = false
		await tween.step_finished
		tween.stop()

func animate_tween_to(target_ratio: float):
	tween.tween_property(PATH_FOLLOW, "progress_ratio", target_ratio, tween_full_duration / 2.0)
