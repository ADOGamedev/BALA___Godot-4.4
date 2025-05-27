extends StaticBody3D

@onready var pine_material = $"MultiMeshInstance3D/tree-pine3".get_surface_override_material(0)
@onready var log_material = $"MultiMeshInstance3D/tree-pine_002".get_surface_override_material(0)

func _ready():
	asign_random_green()
	asign_random_brown()
	pine_material = $"MultiMeshInstance3D/tree-pine3".get_surface_override_material(0)
	pine_material.set_shader_parameter("my_pos", global_position)
	asign_random_movement()
	
func asign_random_green():
	var unique_pine_material = pine_material.duplicate()
	unique_pine_material.set_shader_parameter("green_tone", randf_range(3.5, 5.0))
	$"MultiMeshInstance3D/tree-pine3".set_surface_override_material(0, unique_pine_material)
	pine_material = unique_pine_material
	
func asign_random_brown():
	var unique_material_log = log_material.duplicate()
	unique_material_log.set_shader_parameter("brown_tone", randf_range(2.0, 3.0))
	$"MultiMeshInstance3D/tree-pine_002".set_surface_override_material(0, unique_material_log)

func asign_random_movement():
	var random_vector = Vector2(randf_range(-0.035, 0.045), randf_range(-0.027, 0.03))
	pine_material.set_shader_parameter("movement", random_vector)
