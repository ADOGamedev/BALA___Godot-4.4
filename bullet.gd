extends Node3D

var speed = 35.0
var velocity = Vector3.ZERO
var damage : float
var lifetime : float
var new_weapon = true

func _process(delta: float) -> void:
	global_transform.origin += velocity * delta

func start(xform):
	$Timer.start(lifetime)
	var original_scale = scale
	global_transform = xform
	velocity = global_transform.basis.z * speed
	scale = original_scale

func _on_area_3d_body_entered(body: Node3D) -> void:
	queue_free()
	if body.is_in_group("invisible_platforms"):
		body.reveal_plat()
	if body.is_in_group("enemies"):
		if (body.current_state != body.State.APPEARING
			and body.current_state != body.State.LEAVING
			and body.current_state != body.State.UNDERGROUND):
			if body.is_in_group("fusil_enemies"):
				if body.current_state == body.State.DASHING:
					return
			body.health -= damage
			if body.health > 0:
				body.turn_red()
				
	if body.is_in_group("marionette_enemies") and body.rotation_degrees.x >= -5 and body.rotation_degrees.x <= 5:
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		var marionette_target_rotation = -90.0 if velocity.z < 0 else 90.0
		tween.tween_property(body, "rotation_degrees:x", marionette_target_rotation, 0.7)

func _on_timer_timeout() -> void:
	queue_free()
