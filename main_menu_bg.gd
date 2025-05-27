extends Node3D

var ROTATION_SPEED = 0.06

func _ready() -> void:
	call_deferred("update_world_env")

func _process(delta: float) -> void:
	$Camera3D.rotation.y += ROTATION_SPEED * delta

func update_world_env():
	var env = $WorldEnvironment.environment
	env.sdfgi_enabled = false
	await get_tree().process_frame
	env.sdfgi_enabled = true
