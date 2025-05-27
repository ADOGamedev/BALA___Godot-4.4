extends StaticBody3D

@onready var BIG_COLLISION_SHAPE = $big_colliison_shape
@onready var SMALL_COLLISION_SHAPE = $small_colliison_shape

func _ready() -> void:
	if scale.x <= 1.6:
		BIG_COLLISION_SHAPE.disabled = true
		randomize_rotation()
	else:
		SMALL_COLLISION_SHAPE.disabled = true

func randomize_rotation():
	var rng = RandomNumberGenerator.new()
	rotation_degrees.y = 360 * rng.randf()
