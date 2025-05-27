extends Node3D

@onready var PORTAL_MATERIAL = $MeshInstance3D.get_surface_override_material(0)
@onready var PORTAL_LIGHT = $OmniLight3D
@onready var PARTICLES = $portal_particles
var GREY_PORTAL_COLOR = 0x8c8c8cff
var PURPLE_PORTAL_COLOR = 0x8b00ffff

func _ready() -> void:
	PARTICLES.process_material.scale_min *= scale.x
	PARTICLES.process_material.scale_max *= scale.x
	turn_on_portal(false)

func turn_on_portal(activated: bool):
	var portal_color = PURPLE_PORTAL_COLOR if activated else GREY_PORTAL_COLOR
	var portal_time_scale = Vector2(0.5, 0.7) if activated else Vector2(0.1, 0.2)
	PORTAL_MATERIAL.set_shader_parameter("portal_color", Color.hex(portal_color))
	PORTAL_MATERIAL.set_shader_parameter("time_scale", portal_time_scale)
	PORTAL_LIGHT.visible = activated
	PARTICLES.visible = activated
