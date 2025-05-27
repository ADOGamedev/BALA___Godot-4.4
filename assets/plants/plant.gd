extends Node3D

@onready var plant_material = $plant2.get_surface_override_material(0)

func _ready():
	asign_random_green()
	plant_material.set_shader_parameter("my_pos", global_position)
	asign_random_movement()
	
func asign_random_green():
	var unique_plant_material = plant_material.duplicate()
	plant_material.set_shader_parameter("green_tone", randf_range(3.0, 4.5))
	$plant2.set_surface_override_material(0, unique_plant_material)

func asign_random_movement():
	var random_vector = Vector2(randf_range(-0.035, 0.045), randf_range(-0.027, 0.03))
	plant_material.set_shader_parameter("movement", random_vector)
	plant_material = $plant2.get_surface_override_material(0)
