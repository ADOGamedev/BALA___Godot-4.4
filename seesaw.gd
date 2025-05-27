extends Node3D

@onready var SEESAW : RigidBody3D = $seesaw
var body_count = 0
var RETURNING_ANGULAR_VEL = 0.2

func _physics_process(delta: float) -> void:
	return_to_zero(delta)
	
func return_to_zero(delta: float):
	if body_count == 0:
		SEESAW.rotation_degrees.z = lerpf(SEESAW.rotation_degrees.z, 0.0, RETURNING_ANGULAR_VEL * delta)

func _on_body_detection_area_body_exited(body: Node3D) -> void:
	if !body.is_in_group("seesaw"):
		body_count -= 1
		
func _on_body_detection_area_body_entered(body: Node3D) -> void:
	if !body.is_in_group("seesaw"):
		body_count += 1
