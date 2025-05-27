extends Area3D

@export var damage : int

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage, -body.velocity.normalized())
