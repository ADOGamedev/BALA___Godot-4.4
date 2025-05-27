extends Node3D

var damage := 1
@onready var RAY : RayCast3D = $RayCast3D
var GRAVITY := 60.0

func _ready() -> void:
	disable_or_enable_particles()

func _process(_delta: float) -> void:
	disable_or_enable_particles()

func disable_or_enable_particles():
	if JsonOptionsSaving.options["performance"]["quality_level"] == 2: #* Quiality level low
		$GPUParticles3D.visible = false
	else:
		$GPUParticles3D.visible = true

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		if !body.hitted_by_enemy_trail:
			body.take_damage(damage, -body.velocity.normalized(), 1.5, 0.0, true)
