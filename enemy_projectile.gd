extends StaticBody3D


var speed : float
var velocity = Vector3.ZERO
var damage : int

func _process(delta: float) -> void:
	global_transform.origin += velocity * delta

func start(xform):
	var original_scale = scale
	global_transform = xform
	velocity = global_transform.basis.z * speed
	scale = original_scale

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("shotgun_enemies"):
		return
	if body.is_in_group("player"):
		body.take_damage(damage, -transform.basis.z)
	queue_free()
