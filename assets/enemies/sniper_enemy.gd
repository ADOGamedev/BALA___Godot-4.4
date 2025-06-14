extends CharacterBody3D

@onready var PLAYER : CharacterBody3D
@onready var ANIM_TREE = $AnimationTree
@onready var STATE_MACHINE = ANIM_TREE.get("parameters/playback")
@onready var EXCLAMATION_MARK = $exclamation_mark
@onready var FLOOR_RAY_CAST = $sniper_enemy/Armature/RayCast3D
@onready var BODY_MESH = $sniper_enemy/Armature/Skeleton3D/Cylinder_008

var SPEED := 1.75
var health := 17.0
var damage := 1
var player_pos := Vector3.ZERO
var can_target_player := false
var target_xform : Transform3D
enum State { HAS_APPEARED, APPEARING, UNDERGROUND, LEAVING, SHOOTING }
var current_state: State = State.UNDERGROUND
var player_in := false

var dead = false
var dead_in_floor = false

@onready var HEAD_PARTICLES = %head_particles
@onready var BODY_PARTICLES = %body_particles
@onready var ALL_MESHES : Array = [$sniper_enemy/Torus, $sniper_enemy/Armature/Cylinder_007, $sniper_enemy/Armature/Skeleton3D/Cylinder,
									$sniper_enemy/Armature/Skeleton3D/Cylinder_008, $sniper_enemy/Armature/Skeleton3D/Sphere_001, 
									$sniper_enemy/Armature/Skeleton3D/Sphere_012, $sniper_enemy/Armature/Skeleton3D/Sphere_013,
									$sniper_enemy/Armature/Skeleton3D/Sphere_014, $sniper_enemy/Armature/Cylinder_007]

var distance_to_player : float
var MAX_DISTANCE_TO_PLAYER := 8.0
@onready var SHOOT_TIMER := $Timer
var shoot_timer_timeout := true
var SHOOT_WAIT_TIME = 3.0

@export var projectile_speed := 35.0
@export var projectile_damage := 2
@export var projectile_scale := 0.14

@onready var body_material = BODY_MESH.get_surface_override_material(0)
@onready var body_green = body_material.albedo_color.g

@export var outside_pos_add: float = scale.x * 2.0 #* To contrarest the multiplication in "bullet_enemie_from_the_floor.gd", line 14
@onready var underground_pos : float = position.y
@onready var outside_pos : float = underground_pos + outside_pos_add

func _ready() -> void:
	make_material_unique()
	
func _process(delta):
	var y_pos = position.y

	if dead:
		if !dead_in_floor:
			$sniper_enemy.get_node("AnimationPlayer").play("idle")
			dead_in_floor = true
		return
	if !can_target_player:
		current_state = State.UNDERGROUND
	if SHOOT_TIMER.paused and current_state != State.UNDERGROUND: 
		SHOOT_TIMER.paused = false

	calculate_distance_to_player()
	handle_under_ground_state()
	handle_anim_tree()
	if distance_to_player > MAX_DISTANCE_TO_PLAYER:
		chase_player(delta)
	look_at_player()

	position.y = y_pos

func shoot():
	shoot_timer_timeout = false
	SHOOT_TIMER.start(SHOOT_WAIT_TIME)

	current_state = State.SHOOTING
	await get_tree().create_timer(0.8).timeout #* Is the time that has passed in the animation when the enemy opens the mouth
	current_state = State.HAS_APPEARED
	var new_projectile = load("res://enemy_projectile.tscn").instantiate()
	new_projectile.speed = projectile_speed
	new_projectile.damage = projectile_damage
	new_projectile.scale = Vector3(projectile_scale, projectile_scale, projectile_scale)
	get_parent().owner.add_child(new_projectile)
	new_projectile.start($shooting_pos.global_transform)

func predict_player_pos():
	player_pos += PLAYER.velocity * 0.5 * distance_to_player / 8.0	#* Multiply by 0.5 to match more accuarate the predict

func handle_anim_tree():
	if current_state == State.UNDERGROUND:
		return
	if distance_to_player <= MAX_DISTANCE_TO_PLAYER:
		if shoot_timer_timeout:
			ANIM_TREE.set("parameters/conditions/can_shoot", true)
			ANIM_TREE.set("parameters/conditions/can_walk", false)
			ANIM_TREE.set("parameters/conditions/can_idle", false)

			shoot()
		else:
			ANIM_TREE.set("parameters/conditions/can_shoot", false)
			ANIM_TREE.set("parameters/conditions/can_walk", false)
			ANIM_TREE.set("parameters/conditions/can_idle", true)

	elif current_state != State.SHOOTING:
		ANIM_TREE.set("parameters/conditions/can_shoot", false)
		ANIM_TREE.set("parameters/conditions/can_walk", true)
		ANIM_TREE.set("parameters/conditions/can_idle", false)

func calculate_distance_to_player():
	distance_to_player = (Vector2(PLAYER.global_position.x - global_position.x, 
								PLAYER.global_position.z - global_position.z)).length()

func handle_under_ground_state():
	if current_state == State.UNDERGROUND:
		ANIM_TREE.set("parameters/conditions/can_walk", true)
		SHOOT_TIMER.paused = true

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
	if current_state == State.SHOOTING:
		predict_player_pos()
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
		if mesh.name == "Cylinder_007":
			mesh.set_surface_override_material(1, unique_material)
		mat = unique_material
		mat.transparency = 3 #* Alpha hash
		tween.tween_property(mat, "albedo_color:a", 0.0, 1.1)

	tween.tween_property(HEAD_PARTICLES.draw_pass_1.material, "albedo_color:a", 0.0, 1.1)
	tween.tween_property(BODY_PARTICLES.draw_pass_1.material, "albedo_color:a", 0.0, 1.1)

func turn_red():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false)
	tween.tween_property(body_material, "albedo_color:g", body_green - 50.0/255.0, 0.2)
	tween.tween_property(body_material, "albedo_color:g", body_green - 40.0/255.0, 0.1)
	tween.tween_property(body_material, "albedo_color:g", body_green, 0.2)

func make_material_unique():
	var unique_body_material = body_material.duplicate()
	body_green = unique_body_material.albedo_color.g
	BODY_MESH.set_surface_override_material(0, unique_body_material)
	$sniper_enemy/Armature/Skeleton3D/Cylinder.set_surface_override_material(0, unique_body_material)
	body_material = unique_body_material

func _on_timer_timeout() -> void:
	shoot_timer_timeout = true
