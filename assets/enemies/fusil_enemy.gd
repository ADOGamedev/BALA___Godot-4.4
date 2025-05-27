extends CharacterBody3D

@onready var PLAYER : CharacterBody3D
@onready var ANIM_TREE : AnimationTree = $AnimationTree
@onready var COLLISIONS_ANIM_PLAYER = $collisions_anim_player
@onready var STATE_MACHINE = ANIM_TREE.get("parameters/playback")
@onready var EXCLAMATION_MARK = $exclamation_mark
@onready var FLOOR_RAY_CAST = $Armature/RayCast3D
@onready var HEAD_RAY = $Armature/head_ray
@onready var BODY_MESH = %Cylinder_003
@onready var HEAD_MESH = %Sphere_004
@onready var body_material = BODY_MESH.get_surface_override_material(0)
@onready var body_green = body_material.albedo_color.g
@onready var head_material = HEAD_MESH.get_surface_override_material(0)
@onready var head_green = head_material.albedo_color.g

@onready var HEAD_PARTICLES = $head_particles
@onready var BODY_PARTICLES = $body_particles
@onready var ALL_MESHES : Array = [%Cylinder_001, %Cylinder_003, %Sphere_004, %Sphere_006, %Sphere_007, %Sphere_008]
var collided_with_player = false

@export var SPEED : float = 2.2
@export var health : float = 14.0
@export var damage : int = 2
var player_pos = Vector3()
var can_target_player = false
var target_xform
enum State { HAS_APPEARED, UNDERGROUND, TILTING, DASHING, APPEARING, LEAVING }
var current_state: State = State.UNDERGROUND
var player_in = false
var timer_timeout = false
var dash_speed = 2.8
var first_time = true
var dead = false
var dead_in_floor = false

@export var outside_pos_add: float = 1.41 * scale.x * 2.0 #* To contrarest the multiplication in "bullet_enemie_from_the_floor.gd", line 10
@onready var underground_pos = position.y
@onready var outside_pos = underground_pos + outside_pos_add

func _ready() -> void:
	ANIM_TREE.set("parameters/conditions/has_appeared", false)
	make_material_unique()
	
func _process(delta):
	if PLAYER == null:
		return
	var y_pos = position.y
	
	if dead:
		if !dead_in_floor:
			$AnimationPlayer.play("untilt")
			dead_in_floor = true
		return
	check_head_collision_with_player()
	handle_state_machine()
	handle_timer()
	handle_anim_tree()
	handle_collisions_anim_tree()
	handle_movement(delta)
	if (current_state == State.HAS_APPEARED and STATE_MACHINE.get_current_node() != "untilt") or current_state == State.UNDERGROUND:
		look_at_player()

	position.y = y_pos

func handle_state_machine():
	if !can_target_player or position.y == underground_pos:
		current_state = State.UNDERGROUND
	elif timer_timeout or STATE_MACHINE.get_current_node() == "tilt":
		current_state = State.TILTING
		timer_timeout = false
	elif STATE_MACHINE.get_current_node() == "walk" and current_state != State.UNDERGROUND:
		current_state = State.HAS_APPEARED
	if STATE_MACHINE.get_current_node() == "run":
		current_state = State.DASHING

func handle_anim_tree():
	ANIM_TREE.set("parameters/conditions/is_tilting", current_state == State.TILTING)
	ANIM_TREE.set("parameters/conditions/has_appeared", current_state == State.HAS_APPEARED)

func handle_collisions_anim_tree():
	if COLLISIONS_ANIM_PLAYER.current_animation != "tilt" and STATE_MACHINE.get_current_node() == "tilt":
		COLLISIONS_ANIM_PLAYER.play("tilt")
	if COLLISIONS_ANIM_PLAYER.current_animation != "untilt" and STATE_MACHINE.get_current_node() == "untilt":
		COLLISIONS_ANIM_PLAYER.play("untilt")
		$Timer.start(1.5)

func handle_timer():
	if current_state == State.HAS_APPEARED and first_time:
		$Timer.start(1.0)
		first_time = false

func show_exclamation():
	EXCLAMATION_MARK.visible = true
	EXCLAMATION_MARK.get_node("AnimationPlayer").play("exclamation_mark")
	await get_tree().create_timer(1.149).timeout #* "exlamation_mark" duration
	EXCLAMATION_MARK.visible = false

func handle_movement(delta):
	if (current_state == State.HAS_APPEARED and STATE_MACHINE.get_current_node() != "untilt") or current_state == State.TILTING:
		if FLOOR_RAY_CAST.is_colliding():
			chase_player(delta)
	elif current_state == State.DASHING:
		dash(delta)

func dash(delta):
	if !FLOOR_RAY_CAST.is_colliding() or HEAD_RAY.is_colliding() or collided_with_player:
		undash()
		collided_with_player = false
		return
	chase_player(delta, dash_speed, false)

func undash():
	current_state = State.HAS_APPEARED
	ANIM_TREE.set("parameters/conditions/has_appeared", true)
	player_pos = global_position + global_position.direction_to(player_pos) * Vector3(15.0, 15.0, 15.0)

func chase_player(delta, speed_multiplier: float = 1.0, move_to_player: bool = true):
	if PLAYER.health <= 0:
		return
	if can_target_player:
		player_pos = player_pos if move_to_player else global_position + global_position.direction_to(player_pos) * Vector3(15.0, 15.0, 15.0)
		global_position = global_position.move_toward(player_pos, delta * SPEED * speed_multiplier)
		velocity *= SPEED * speed_multiplier
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

func check_head_collision_with_player():
	if HEAD_RAY.is_colliding():
		if HEAD_RAY.get_collider().is_in_group("player"):
			get_parent().get_parent().owner.PLAYER.take_damage(damage, -transform.basis.z)
			undash()

func die():
	can_target_player = false
	dead = true
	current_state = State.HAS_APPEARED
	ANIM_TREE.set("parameters/conditions/has_appeared", true)
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
	
func _on_timer_timeout() -> void:
	timer_timeout = true
	
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
