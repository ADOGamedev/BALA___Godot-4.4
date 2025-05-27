extends CharacterBody3D

@onready var PLAYER : CharacterBody3D
@onready var ANIM_TREE = $AnimationTree
@onready var STATE_MACHINE = ANIM_TREE.get("parameters/playback")
@onready var EXCLAMATION_MARK = $exclamation_mark
@onready var FLOOR_RAY_CAST = $Armature/RayCast3D
@onready var BODY_MESH = %Sphere_002
@onready var HEAD_MESH = %Sphere_003
@onready var EYE1_MESH = %Sphere_001
@onready var EYE2_MESH = %Sphere
@onready var MOUTH_MESH = %Cylinder

var ALL_MESHES : Array

@onready var HEAD_PARTICLES = $head_particles
@onready var BODY_PARTICLES = $body_particles

var SPEED : float = 2.0
var health : float = 8.0
var damage : int = 1
var player_pos = Vector3()
var can_target_player = false
var target_xform
enum State { HAS_APPEARED, APPEARING, UNDERGROUND, LEAVING }
var current_state: State = State.UNDERGROUND
var player_in = false
var dead = false

@onready var body_material = BODY_MESH.get_surface_override_material(0)
@onready var body_green = body_material.albedo_color.g
@onready var head_material = HEAD_MESH.get_surface_override_material(0)
@onready var head_green = head_material.albedo_color.g

@export var outside_pos_add: float = scale.x * 2.0 #* To contrarest the multiplication in "bullet_enemie_from_the_floor.gd", line 14
@onready var underground_pos = position.y
@onready var outside_pos = underground_pos + outside_pos_add

func _ready() -> void:
	ALL_MESHES = [BODY_MESH, HEAD_MESH, EYE1_MESH, EYE2_MESH, MOUTH_MESH]

	ANIM_TREE.set("parameters/conditions/has_appeared", false)
	make_material_unique()
	
func _process(delta):
	var y_pos = position.y

	if dead:
		return
	if !can_target_player:
		current_state = State.UNDERGROUND
	check_has_appeared()
	chase_player(delta)
	look_at_player()

	position.y = y_pos

func check_has_appeared():
	ANIM_TREE.set("parameters/conditions/has_appeared", current_state == State.HAS_APPEARED)

func show_exclamation():
	EXCLAMATION_MARK.visible = true
	EXCLAMATION_MARK.get_node("AnimationPlayer").play("exclamation_mark")
	await get_tree().create_timer(1.149).timeout #* "exlamation_mark" duration
	EXCLAMATION_MARK.visible = false

func chase_player(delta):
	if PLAYER.health <= 0:
		return
	if FLOOR_RAY_CAST.is_colliding():
		if can_target_player:
			global_position = global_position.move_toward(player_pos, delta * SPEED)
			velocity *= SPEED
			set_velocity(velocity)
			move_and_slide()
		else:
			velocity = Vector3.ZERO

func look_at_player():
	player_pos = PLAYER.global_position
	var original_scale = scale
	var original_pos = global_position

	target_xform = global_transform.looking_at(player_pos, Vector3.UP)
	global_transform = global_transform.interpolate_with(target_xform, 0.2)

	scale = original_scale
	global_position = original_pos
	rotation.z = 0
	rotation.x = 0

func die():
	can_target_player = false
	dead = true
	$CollisionShape3D.disabled = true
	set_collision_mask_value(2, false)
	set_collision_layer_value(4, false)
	$AnimationTree.active = false
	fall()
	await get_tree().create_timer(1.1).timeout #* Falling duration
	vanish()
	await get_tree().create_timer(1.1).timeout #* Meshes vanish duration
	BODY_PARTICLES.emitting = false
	HEAD_PARTICLES.emitting = false
	await get_tree().create_timer(1.5).timeout #* Time for particles to vanish
	queue_free()

func fall():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees", rotation_degrees + Vector3(85.0, 0, 85.0), 0.8)

func vanish():
	BODY_PARTICLES.visible = true
	HEAD_PARTICLES.visible = true

	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	for mesh in ALL_MESHES:
		var mat = mesh.get_surface_override_material(0)
		var unique_material = mat.duplicate()
		mesh.set_surface_override_material(0, unique_material)
		mat = unique_material
		mat.transparency = 3 #* Alpha hash
		tween.tween_property(mat, "albedo_color:a", 0.0, 1.1)

	tween.tween_property(HEAD_PARTICLES.draw_pass_1.material, "albedo_color:a", 0.0, 1.1)
	tween.tween_property(BODY_PARTICLES.draw_pass_1.material, "albedo_color:a", 0.0, 1.1)

func turn_red():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false)
	var tween2 = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false)
	tween.tween_property(body_material, "albedo_color:g", body_green - 50.0/255.0, 0.2)
	tween.tween_property(body_material, "albedo_color:g", body_green - 40.0/255.0, 0.1)
	tween.tween_property(body_material, "albedo_color:g", body_green, 0.2)
	
	tween2.tween_property(head_material, "albedo_color:g", head_green - 50.0/255.0, 0.2)
	tween2.tween_property(head_material, "albedo_color:g", head_green - 40.0/255.0, 0.1)
	tween2.tween_property(head_material, "albedo_color:g", head_green, 0.2)

func make_material_unique():
	var unique_body_material = body_material.duplicate()
	body_green = unique_body_material.albedo_color.g
	BODY_MESH.set_surface_override_material(0, unique_body_material)
	body_material = unique_body_material
	
	var unique_head_material = head_material.duplicate()
	head_green = unique_head_material.albedo_color.g
	HEAD_MESH.set_surface_override_material(0, unique_head_material)
	head_material = unique_head_material
	
