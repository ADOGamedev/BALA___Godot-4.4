extends StaticBody3D

@onready var MESH = $MeshInstance3D
@onready var MESH_MAT = $MeshInstance3D.get_surface_override_material(0) as BaseMaterial3D

var REVEAL_COLOR = Color.hex(0x009a9cff)
var HIDE_COLOR = Color.hex(0x009a9c00)

@export var SHOWING_TIME := 0.8

func _ready():
	make_material_unique()
	MESH_MAT.albedo_color = HIDE_COLOR

func make_material_unique():
	var unique_material = MESH_MAT.duplicate()
	MESH.set_surface_override_material(0, unique_material)
	MESH_MAT = MESH.get_surface_override_material(0)
	
func reveal_plat():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false)
	tween.tween_property(MESH_MAT, "albedo_color", REVEAL_COLOR, 0.2)
	tween.tween_property(MESH_MAT, "albedo_color", HIDE_COLOR, SHOWING_TIME)
