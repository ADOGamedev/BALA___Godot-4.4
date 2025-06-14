extends RigidBody3D

var is_strong := true

func _process(_delta: float) -> void:
    $strong_crate.visible = is_strong
    $crate2.visible = !is_strong

func _on_area_body_entered(body: PhysicsBody3D):
    if body.is_in_group("player"):
        is_strong = false
    
func _on_area_body_exited(body: PhysicsBody3D):
    if body.is_in_group("player"):
        is_strong = true

