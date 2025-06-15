extends CharacterBody3D

@onready var PLAYER : CharacterBody3D
@onready var ANIM_TREE = $AnimationTree
@onready var STATE_MACHINE = $AnimationTree.get("parameters/playback")
@onready var EXCLAMATION_MARK = $exclamation_mark
@onready var FLOOR_RAY_CAST = $Armature/RayCast3D
@onready var BODY_MESH = %Cylinder_006
@onready var HEAD_MESH = %Cylinder_005

@onready var ALL_MESHES : Array = [%Cylinder_010, %Cylinder_005, %Cylinder_006, %Sphere_001, %Sphere_015, %Sphere_016, %Sphere_017]
@onready var HEAD_PARTICLES = $head_particles
@onready var BODY_PARTICLES = $body_particles

@onready var SHOOTING_POSITIONS : Array = $shooting_positions.get_children()
@onready var SHELL_FRAGMENTS : Array = [$Plane, $Plane_001, $Plane_002, $Plane_003, $Plane_004, $Plane_005]
@onready var shells_forward_dir : Array = []

var SPEED : float = 2.5
var health : float = 20.0
var previous_health : float = 20.0
var damage : int = 2
var player_pos = Vector3()
var can_target_player = false
var target_xform
enum State { HAS_APPEARED, APPEARING, UNDERGROUND, LEAVING }
var current_state: State = State.UNDERGROUND
var player_in = false
var dead = false

var head_exploted = false

var distance_to_player : float

@export var projectile_speed := 26.0
@export var projectile_damage := 2
@export var projectile_scale := 0.1

@onready var body_material = %Cylinder_006.get_surface_override_material(0)
@onready var body_green = body_material.albedo_color.g
@onready var head_material = %Cylinder_005.get_surface_override_material(0)
@onready var head_green = head_material.albedo_color.g

@export var outside_pos_add: float = scale.x * 2.0 #* To contrarest the multiplication in "bullet_enemie_from_the_floor.gd", line 14
@onready var underground_pos = position.y
@onready var outside_pos = underground_pos + outside_pos_add

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	ANIM_TREE.set("parameters/conditions/has_appeared", false)
	make_material_unique()
	calculate_shells_forward_dir()
	
func _process(delta):
	var y_pos = position.y
	rng.randomize()

	if dead:
		shake(0.0)
		explode_head(delta)
		return
	if !can_target_player:
		current_state = State.UNDERGROUND

	calculate_distance_to_player()
	update_shake()
	check_has_appeared()
	chase_player(delta)
	look_at_player()

	position.y = y_pos
	previous_health = health

func shoot():
	for shooting_pos in SHOOTING_POSITIONS:
		var new_projectile = load("res://enemy_projectile.tscn").instantiate()
		new_projectile.speed = projectile_speed
		new_projectile.damage = projectile_damage
		new_projectile.scale = Vector3(projectile_scale, projectile_scale, projectile_scale)
		get_parent().owner.add_child(new_projectile)
		new_projectile.start(shooting_pos.global_transform)

func calculate_distance_to_player():
	distance_to_player = (Vector2(PLAYER.global_position.x - global_position.x, 
								PLAYER.global_position.z - global_position.z)).length()

func predict_player_pos():
	player_pos += PLAYER.velocity * 0.6 * distance_to_player / 8.0	#* Multiply by 0.6 to match more accuarate the predict

func calculate_shells_forward_dir():
	for shell in SHELL_FRAGMENTS:
		shells_forward_dir.push_back(-shell.transform.basis.y)

func vanish_head_particles():
	HEAD_PARTICLES.visible = true
	await get_tree().create_timer(1.1).timeout
	HEAD_PARTICLES.emitting = false
	await get_tree().create_timer(1.5).timeout #* Time for particles to vanish
	HEAD_PARTICLES.queue_free()

func explode_head(delta: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
	for i in range(SHELL_FRAGMENTS.size()):
		var shell = SHELL_FRAGMENTS[i]
		shell.visible = true
		HEAD_MESH.visible = false
		shell.transform = shell.transform.rotated_local(Vector3.RIGHT, rad_to_deg(50.0 * delta))
		shell.position.y += 20.0 * delta
		shell.position += shells_forward_dir[i] * 30.0 * delta
	if head_exploted:
		return
	head_exploted = true
	for shell in SHELL_FRAGMENTS:
		var mat = shell.get_surface_override_material(0)
		var unique_mat = shell.get_surface_override_material(0).duplicate()
		shell.set_surface_override_material(0, unique_mat)
		mat = unique_mat
		mat.transparency = 3 #* Alpha hash
		tween.tween_property(mat, "albedo_color:a", 0.0, 1.0)

func shake(intensity: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_loops()
	rng.randomize()
	var random_x = ((rng.randf() - 0.5) * intensity) / 3 
	rng.randomize()
	var random_z = ((rng.randf() - 0.5) * intensity) / 3 

	tween.tween_property(HEAD_MESH, "position:x", random_x, 0.03)
	tween.tween_property(HEAD_MESH, "position:z", random_z, 0.03)

	tween.tween_property(HEAD_MESH, "position", Vector3(0, HEAD_MESH.position.y, 0.0), 0.03)

func update_shake():
	if health <= 0:
		return
	if previous_health != health:
		var intensity = (20.0 - health) / 20.0  #* 20.0 is the original health
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(true)
		tween.tween_property(HEAD_MESH, "scale:x", 1.4 * intensity + 1.0, 0.2)
		tween.tween_property(HEAD_MESH, "scale:z", 1.4 * intensity + 1.0, 0.2)

		shake(intensity)

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
	predict_player_pos()
	var previous_scale = scale
	global_transform = global_transform.looking_at(player_pos)
	scale = previous_scale

	dead = true
	vanish_head_particles()
	shoot()
	can_target_player = false
	await get_tree().create_timer(1.5).timeout
	$CollisionShape3D.disabled = true
	set_collision_mask_value(2, false)
	set_collision_layer_value(4, false)
	$AnimationTree.active = false
	fall()
	await get_tree().create_timer(1.1).timeout #* Falling duration
	vanish()
	await get_tree().create_timer(1.1).timeout #* Meshes vanish duration
	BODY_PARTICLES.emitting = false
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
	
