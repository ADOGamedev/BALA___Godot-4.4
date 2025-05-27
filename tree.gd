extends StaticBody3D

@onready var tree_material = $MultiMeshInstance3D/Group.get_surface_override_material(0)
@onready var log_material = $MultiMeshInstance3D/tree3.get_surface_override_material(0)

func _ready():
	asign_random_green()
	asign_random_brown()
	tree_material = $MultiMeshInstance3D/Group.get_surface_override_material(0)
	tree_material.set_shader_parameter("my_pos", global_position)
	asign_random_movement()
		
func asign_random_green():
	var unique_tree_material = tree_material.duplicate()
	unique_tree_material.set_shader_parameter("green_tone", randf_range(2.5, 4.0))
	$MultiMeshInstance3D/Group.set_surface_override_material(0, unique_tree_material)
	tree_material = unique_tree_material
		
func asign_random_brown():
	var unique_log_material = log_material.duplicate()
	unique_log_material.set_shader_parameter("brown_tone", randf_range(2.0, 3.0))
	$MultiMeshInstance3D/tree3.set_surface_override_material(0, unique_log_material)

func asign_random_movement():
	var random_vector = Vector2(randf_range(-0.035, 0.045), randf_range(-0.027, 0.03))
	tree_material.set_shader_parameter("movement", random_vector)
