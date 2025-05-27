extends Node3D

@onready var grass_material = $grass2.get_surface_override_material(0)

func _ready():
	asign_random_green()
	grass_material.set_shader_parameter("my_pos", global_position)
	asign_random_movement()

func asign_random_green():
	var unique_grass_material = grass_material.duplicate()
	grass_material.set_shader_parameter("green_tone", randf_range(2.7, 4.0))
	$grass2.set_surface_override_material(0, unique_grass_material)
	
func asign_random_movement():
	var random_vector = Vector2(randf_range(-0.035, 0.045), randf_range(-0.027, 0.03))
	grass_material.set_shader_parameter("movement", random_vector)
	grass_material = $grass2.get_surface_override_material(0)
