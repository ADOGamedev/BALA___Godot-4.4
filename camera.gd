extends Camera3D

var trauma_reduction_rate := 1.0

var max_x := 10.0
var max_y := 10.0
var max_z := 5.0

@export var noise : Noise
@export var noise_speed := 30.0

var trauma := 0.0

var time := 0.0

@onready var initial_rotation := rotation_degrees as Vector3

@onready var idle_shake_tween := get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false).set_loops()

func _process(delta: float) -> void:
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)
	
func add_trauma(trauma_amount: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "trauma", trauma_amount, 0.2)
	trauma = clamp(trauma, 0.0, 1.0)

func get_shake_intensity() -> float:
	return trauma * trauma * 2.25

func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)

func idle_shake():
	idle_shake_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false).set_loops()
	idle_shake_tween.tween_property(self, "rotation_degrees:x", 0.75, 1.2)
	idle_shake_tween.tween_property(self, "rotation_degrees:x", -0.75, 1.2)
