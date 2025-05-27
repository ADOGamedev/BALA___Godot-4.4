extends Node3D

@onready var FALL_TIMER = $counter_to_fall
@onready var RESPAWN_TIMER = $respawn
@onready var FALLING_BLOCK = $"block-moving-blue/block-moving-blue"
@onready var STARTING_SCALE = $"block-moving-blue".scale
@onready var AREA_COLLISION = $"block-moving-blue/Area3D/CollisionShape3D2"

@export var tween_full_duration : float = 6.0
@export var can_move = false

var shake_tween : Tween

func _ready() -> void:
	if can_move:
		start_moving_tween()
	start_shaky_effect()

func start_shaky_effect():
	shake_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_loops().set_parallel(false)
	shake_tween.tween_property(self, "position:x", position.x - 0.02, 0.1)
	shake_tween.tween_property(self, "position:x", position.x + 0.02, 0.1)

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		FALL_TIMER.start()

func fall():
	AREA_COLLISION.disabled = true
	await animate_fall_tween()
	$"block-moving-blue/CollisionShape3D".disabled = true
	FALLING_BLOCK.visible = false
	$"block-moving-blue/alpha_mesh".visible = true

func respawn():
	FALLING_BLOCK.visible = true
	$"block-moving-blue/CollisionShape3D".disabled = false
	await animate_respawn_tween()
	$"block-moving-blue/alpha_mesh".visible = false
	AREA_COLLISION.disabled = false

func _on_respawn_timeout() -> void:
	respawn()

func animate_fall_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(FALLING_BLOCK, "scale", STARTING_SCALE * Vector3(1.2, 1, 1.2), 0.3)
	tween.tween_property(FALLING_BLOCK, "scale", STARTING_SCALE * Vector3(0, 0, 0), 0.2)
	await tween.finished
	shake_tween.stop()

func animate_respawn_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(FALLING_BLOCK, "scale", STARTING_SCALE * Vector3(0, 0, 0), 0.2)
	tween.tween_property(FALLING_BLOCK, "scale", STARTING_SCALE * Vector3(1.2, 1, 1.2), 0.3)
	await tween.finished
	start_shaky_effect()

func _on_counter_to_fall_timeout() -> void:
	fall()
	RESPAWN_TIMER.start()

func start_moving_tween():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_loops().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property($Path3D/PathFollow3D, "progress_ratio", 1.0, tween_full_duration / 2)
	tween.tween_property($Path3D/PathFollow3D, "progress_ratio", 0.0, tween_full_duration / 2)
