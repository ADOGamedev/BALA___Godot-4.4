extends Node3D

@export var chest : Node3D

func _on_area_3d_body_entered(body:Node3D) -> void:
    if body.is_in_group("player"):
        chest.player_has_key = true
        queue_free()
