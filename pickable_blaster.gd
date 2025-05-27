extends Node3D

@export var blaster : PackedScene
@onready var BLASTER_NODE = blaster.instantiate()
@onready var MESH_MAT = $pickable_blaster/MeshInstance3D.get_surface_override_material(0)
@onready var LIGHT = $OmniLight3D

var my_id = ""
var color : Color
var DISOLVE_HEIGHT = 5.0

func _ready() -> void:
	my_id = name
	await owner.ready
	if JsonLootSavingLoading.player_loot.has(my_id):
		if JsonLootSavingLoading.player_loot[my_id] == false:
			queue_free()
	
	setup_light_and_material()
	setup_blaster()

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		var blaster_path = blaster.get_path()
		JsonLootSavingLoading.set_value(my_id, false)
		if SaveLoadPlayerStats.player_stats["player_available_weapons"].has(blaster_path):
			queue_free()
			return
		give_weapon_to_player(blaster_path, body)
		owner.get_node("weapon_menu").add_new_weapon()
		queue_free()

func give_weapon_to_player(blaster_path: String, body: Node3D):
	SaveLoadPlayerStats.player_stats["player_available_weapons"].append(blaster_path)
	SaveLoadPlayerStats.player_stats["player_current_weapon"] = blaster_path
	body.switch_weapon_to(body.available_weapons.find(SaveLoadPlayerStats.player_stats["player_current_weapon"]))

func setup_blaster():
	BLASTER_NODE.name = "blaster"
	$pickable_blaster.add_child(BLASTER_NODE)
	BLASTER_NODE.position.y += 0.8

func setup_light_and_material():
	var unique_material = MESH_MAT.duplicate()
	unique_material.set_shader_parameter("color", color)
	MESH_MAT.set_shader_parameter("disolve_height", DISOLVE_HEIGHT + global_position.y)
	$pickable_blaster/MeshInstance3D.set_surface_override_material(0, unique_material)
	color = BLASTER_NODE.color
	LIGHT.light_color = color