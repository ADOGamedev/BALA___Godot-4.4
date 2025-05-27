extends CharacterBody3D

@onready var CAMERA = $pivot/Camera3D
@onready var PIVOT = $pivot
@onready var AREA_COLLISION_SHAPE = $Area3D/CollisionShape3D2
@onready var COLLISION_SHAPE = $CollisionShape3D
@onready var LADDER_RAY = $ladder_ray
@onready var SHOOTING_TIMER = $shooting_timer
@onready var CEILING_RAY = $ceiling_ray
@onready var SFX_DIAMOND = $sfx_diamond
@onready var SFX_COIN = $sfx_coin
@onready var SFX_FOOTSTEPS = $sfx_footsteps
@onready var SFX_BLASTER = $sfx_blaster
@onready var SFX_GET_DAMAGE = $sfx_get_damage
@onready var SFX_LANDING = $sfx_landing

var seesaw: Node3D
var moving_platform: Node3D

var coins = 0
var diamonds = 0

var GRAVITY = Vector3.DOWN * 20
var WALKING_SPEED = 242.7
var RUNNING_SPEED = 364.0
var speed = WALKING_SPEED
var JUMP = 6.0
var can_move = true 
var move_control = 1.0
var LOWER_MOVE_CONTROL = 0.6
var NORMALIZED_Y_STRENGTH = 0.9
var is_jumping = false
var is_moving = false
var is_crouching = false
var weight = 10.0
var on_seesaw = false
var on_moving_platform = false
var is_running = false
var acceleration_deceleration = 12.0
var crouch_states = {
	"crouching": {
		"fov": 65.0,
		"speed_multiplier": 0.4,
		"height": 1.2,
		"pos_y": 0.5,
		"pivot_pos_y": 0.9
	},
	"default": {
		"fov": 75.0,
		"speed_multiplier": 1.0,
		"height": 1.7,
		"pos_y": 0.76,
		"pivot_pos_y": 1.4
	}
}

@export var load_weapons_from_global : bool
@export var available_weapons : Array = []
var current_weapon : String

var has_weapon = false
var bullet_color : Color
var BULLET_SCENE = preload("res://bullet.tscn")
var can_shoot = true
var Z_POS_TO_HIDE_WEAPON = 0.4

var weapon_stats = {
	"shooting_speed" : 0.0,
	"bullet_damage" : 0.0,
	"bullet_lifetime" : 0.0,
	"bullet_size" : 0.0,
	"bullet_z_size" : 0.0,
	"bullet_speed" : 0.0,
}

var MOUSE_SENSIBILITY = 0.0017
var SENSIBILITY_DENOMINATOR = 15000
var CAMERA_UP_DOWN_LIMIT = 1.2

var health = 4
var max_health = 4
var is_invencible = false
var is_dead = false
var hitted_by_enemy_trail = false

var COYOTE_FRAMES = 2.0
var in_coyote = false
var last_floor = false

var INPUT_BUFFER_FRAMES = 10.0
var in_input_buffer = false

var is_next_to_ladder = false
var is_climbing_ladder = false
var LADDDER_Y_SPEED = 2
var LADDER_GRAVITY = Vector3.DOWN * 90

var FLOOR_MAX_ANGLE = 45
var SEESAW_MAX_ANGLE = 30

var FOOTSTEPS_TIME = {"crouching": 0.55,
					"walking": 0.4,
					"running": 0.3}
	
func _ready() -> void:
	$coyote_timer.wait_time = COYOTE_FRAMES / 60.0
	set_up_direction(Vector3.UP)
	set_floor_stop_on_slope_enabled(true)
	update_all_weapon_stats_onready()
	update_health_onready()
	play_sfx_footsteps()

func not_load_weapons_from_global():
	var available_weapon_path: String
	for scene in available_weapons:
		available_weapon_path = scene.get_path()
		SaveLoadPlayerStats.player_stats["player_available_weapons"].append(available_weapon_path)

	SaveLoadPlayerStats.player_stats["player_current_weapon"] = SaveLoadPlayerStats.player_stats["player_available_weapons"][0]
	load_weapons_from_global = true
	SaveLoadPlayerStats.player_stats["player_has_loaded_weapons"] = true

func update_all_weapon_stats_onready():
	if !load_weapons_from_global and !SaveLoadPlayerStats.player_stats["player_has_loaded_weapons"]:
		not_load_weapons_from_global()

	available_weapons = SaveLoadPlayerStats.player_stats["player_available_weapons"]
	var current_weapon_index = available_weapons.find(SaveLoadPlayerStats.player_stats["player_current_weapon"])
	if current_weapon_index != -1:
		current_weapon = available_weapons[current_weapon_index]
	update_weapon()

	var player_current_weapon_index = SaveLoadPlayerStats.player_stats["player_available_weapons"].find(SaveLoadPlayerStats.player_stats["player_current_weapon"])
	if player_current_weapon_index != -1:
		switch_weapon_to(player_current_weapon_index)
	owner.get_node("weapon_menu").add_new_weapon()
	update_weapon_stats()

func update_health_onready():
	health = SaveLoadPlayerStats.player_stats["health"]
	max_health = SaveLoadPlayerStats.player_stats["max_health"]

func _unhandled_input(event):
	move_camera(event)

func _physics_process(delta: float) -> void:
	has_weapon = PIVOT.has_node("blaster")
	update_sensibility()
	update_platforms()
	update_floor_max_angle()
	handle_movement(delta)
	handle_idle_camera_shake()
	handle_weapons()
	check_death()
	apply_gravity(delta)

func handle_idle_camera_shake():
	if health <= 0:
		CAMERA.idle_shake_tween.stop()
		return
	if Input.get_vector("left", "right", "back", "forward") == Vector2.ZERO and is_on_floor():
		if !CAMERA.idle_shake_tween.is_running():
			CAMERA.idle_shake()
	else:
		CAMERA.idle_shake_tween.stop()
		
func handle_movement(delta: float):
	get_input(delta)
	move_and_slide()

func handle_weapons():
	update_weapon_stats()
	update_bullet_color()
	if has_weapon and Input.is_action_pressed("shoot") and can_shoot:
		handle_shooting()

func get_input(delta: float):
	if !can_move:
		return
	
	var y_vel = velocity.y
	speed = WALKING_SPEED
	is_running = false
	is_moving = false
	is_crouching = false
	CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.2)

	var move_forward_back = Input.get_axis("back", "forward")
	var input_dir = Input.get_vector("left", "right", "back", "forward")
	if input_dir != Vector2.ZERO:
		is_moving = true
	handle_crouching()
	handle_running(move_forward_back)

	move(delta, y_vel, input_dir)

	handle_jumping()
	handle_coyote()
	handle_climb_ladder(move_forward_back)

	set_velocity(velocity)

func move(delta: float, y_vel: float, input_dir: Vector2):
	move_control = 1.0
	reduce_move_control()
	
	input_dir = input_dir.normalized()
	if is_jumping:
		input_dir.x *= move_control

	var movement_dir = transform.basis * Vector3(-input_dir.x, 0, input_dir.y)
	var target_velocity = movement_dir * speed * delta
	
	velocity = velocity.lerp(target_velocity, acceleration_deceleration * delta)
	velocity.y = y_vel

func update_bullet_color():
	if PIVOT.has_node("blaster"):
		bullet_color = PIVOT.get_node("blaster").color

func update_platforms():
	for ray in $platforms_rays.get_children():
		if ray.is_colliding():
			detect_platforms(ray)
		else:
			on_moving_platform = false
			on_seesaw = false
		
func detect_platforms(ray: RayCast3D):
	if ray.get_collider().is_in_group("seesaw"):
		on_seesaw = true
		seesaw = ray.get_collider()

	if is_instance_valid(ray.get_collider().owner):
		if ray.get_collider().owner.is_in_group("moving_block"):
			on_moving_platform = true
			moving_platform = ray.get_collider().owner

	handle_platforms_behaviour()

func update_floor_max_angle():
	if on_seesaw:
		floor_max_angle = deg_to_rad(SEESAW_MAX_ANGLE)
	elif is_on_floor():
		floor_max_angle = deg_to_rad(FLOOR_MAX_ANGLE)

func handle_platforms_behaviour():
	if on_seesaw:
		seesaw.apply_force(Vector3(0, -weight, 0), (global_position - seesaw.global_position).normalized())
		
	if on_moving_platform:
		if moving_platform.move_when_player_on_top:
			if !(moving_platform.PATH_FOLLOW.progress_ratio == 0 or moving_platform.PATH_FOLLOW.progress_ratio == 1):
				await moving_platform.tween_finished
				await get_tree().process_frame
				moving_platform.can_move = true
			else:
				moving_platform.can_move = true
	elif moving_platform != null:
		if moving_platform.move_when_player_on_top:
			moving_platform.can_move = false

func show_stun_screen():
	var stun_screen = owner.UI.get_node("stun_screen")
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	stun_screen.visible = true
	tween.tween_property(stun_screen, "color:a", 0.0, 2.0)
	await tween.finished
	stun_screen.visible = false
	stun_screen.color.a = 1.0

func take_damage(value: int, enemy_direction: Vector3, xform_multiplier: float = 1.5, invencibility_time: float = 0.5, hitted_by_trail: bool =  false):
	if is_invencible:
		return
	add_camera_trauma(1.0)
	is_invencible = true
	SFX_GET_DAMAGE.play()
	owner.get_node("ui").tween_damage_vignete()
	health -= value
	velocity = enemy_direction * speed * xform_multiplier / Engine.get_frames_per_second() #* Equivalent to multiply by delta
	velocity.y = JUMP
	can_move = false
	if hitted_by_trail:
		hitted_by_enemy_trail = true
	await get_tree().create_timer(invencibility_time).timeout
	is_invencible = false
	can_move = true
	if hitted_by_trail:
		await get_tree().create_timer(0.5).timeout
		hitted_by_enemy_trail = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		if body.dead:
			return
		if body.is_in_group("tracer_enemies"):
			take_damage(body.damage, -body.transform.basis.z, 4.0)
		elif body.get_parent().is_in_group("mini_enemies"):
			take_damage(body.damage, -body.transform.basis.z, 4.0)
		else:
			take_damage(body.damage, -body.transform.basis.z)
		if body.is_in_group("fusil_enemies"):
			body.collided_with_player = true

func move_camera(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSIBILITY)
		PIVOT.rotate_x(event.relative.y * MOUSE_SENSIBILITY)
		PIVOT.rotation.x = clamp(PIVOT.rotation.x, -CAMERA_UP_DOWN_LIMIT, CAMERA_UP_DOWN_LIMIT)

func shoot(marker: Marker3D):
	SHOOTING_TIMER.start(weapon_stats["shooting_speed"])

	var bullet = BULLET_SCENE.instantiate()
	var bullet_shader = bullet.get_node("bullet_laser/meshes/laser").mesh.material as ShaderMaterial
	var bullet_xform = marker.global_transform
	SFX_BLASTER.play()
	add_camera_trauma(0.3)
	set_bullet_variables(bullet, bullet_shader)
	get_parent().add_child(bullet)
	bullet.start(bullet_xform)

func set_bullet_variables(bullet: Node3D, bullet_shader: ShaderMaterial):
	bullet_shader.set_shader_parameter("bullet_color", bullet_color)
	bullet.scale = Vector3.ONE
	bullet.scale *= weapon_stats["bullet_size"]
	bullet.get_node("bullet_laser").scale.z *= weapon_stats["bullet_z_size"]
	bullet.damage = weapon_stats["bullet_damage"]
	bullet.lifetime = weapon_stats["bullet_lifetime"]
	bullet.speed = weapon_stats["bullet_speed"]

func handle_shooting():
	can_shoot = false
	for marker in PIVOT.get_node("blaster").get_children():
		if marker is Marker3D:
			shoot(marker)

func handle_jumping():
	if is_on_floor():
		if is_jumping:
			is_jumping = false
			SFX_LANDING.play()
			add_camera_trauma(0.45)
		elif in_input_buffer and !Input.is_action_pressed("jump"):
			jump()

	if Input.is_action_just_pressed("jump"):
		if true: #(is_on_floor() or in_coyote) and !is_jumping:
			jump()
		else:
			in_input_buffer = true
			get_tree().create_timer(INPUT_BUFFER_FRAMES / 60.0).timeout.connect(_on_input_buffer_timeout)

func jump():
	velocity.y += JUMP
	is_jumping = true

func _on_input_buffer_timeout() -> void:
	in_input_buffer = false

func handle_running(move_forward_back: int):
	if Input.is_action_pressed("run"):
		is_running = true
	if is_running and move_forward_back > 0:
		run()

func run():
	CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.2)
	speed = RUNNING_SPEED

func handle_crouching():
	if Input.is_action_pressed("crouch") or CEILING_RAY.is_colliding():
		apply_crouch_state(crouch_states["crouching"])
		is_crouching = true
	else:
		apply_crouch_state(crouch_states["default"])

func apply_crouch_state(state: Dictionary):
	CAMERA.fov = lerp(CAMERA.fov, state["fov"], 0.2)
	speed *= state["speed_multiplier"]
	COLLISION_SHAPE.shape.height = state["height"]
	COLLISION_SHAPE.position.y = state["pos_y"]
	AREA_COLLISION_SHAPE.position.y = state["pos_y"]
	PIVOT.position.y = lerp(PIVOT.position.y, state["pivot_pos_y"], 0.2)

func check_death():
	if is_dead:
		return
	if health <= 0:
		is_dead = true
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).set_parallel(true)
		tween.tween_property(self, "rotation_degrees:x", -85.0, 1.1)
		tween.tween_property(self, "rotation_degrees:z", 85.0, 1.1)
		await tween.finished
		owner.show_dead_screen()

func _on_coyote_timer_timeout() -> void:
	in_coyote = false

func handle_jump_off_ladder(move_forward_back: int):
	if is_next_to_ladder and Input.is_action_pressed("jump") and move_forward_back > 0:
		velocity.y += JUMP

func handle_climb_ladder(move_forward_back: int):
	if LADDER_RAY.is_colliding() and LADDER_RAY.get_collider().is_in_group("ladder"):
		is_next_to_ladder = true
		if Input.is_action_pressed("jump") and is_next_to_ladder:
			climb_ladder()
	else:
		handle_jump_off_ladder(move_forward_back)
		is_next_to_ladder = false
	is_climbing_ladder = false

func climb_ladder():
	velocity.y = LADDDER_Y_SPEED
	is_climbing_ladder = true

func apply_gravity(delta):
	if is_next_to_ladder:
		velocity.y = LADDER_GRAVITY.y * delta

	elif !is_on_floor():
		velocity += GRAVITY * delta

func reduce_move_control():
	if is_jumping or is_climbing_ladder:
		move_control = LOWER_MOVE_CONTROL

func handle_coyote():
	if !is_on_floor() and last_floor and !is_jumping:
		in_coyote = true
		$coyote_timer.start()

	last_floor = is_on_floor()

func switch_weapon_to(new_index: int):
	current_weapon = available_weapons[new_index]
	SaveLoadPlayerStats.player_stats["player_current_weapon"] = current_weapon
	await save_weapon()
	update_weapon()
	await take_out_weapon()

func update_weapon():
	if current_weapon == null or current_weapon == "":
		return
	if PIVOT.has_node("blaster"):
		PIVOT.remove_child(PIVOT.get_node("blaster"))

	var new_weapon = load(current_weapon).instantiate()
	new_weapon.name = "blaster"
	new_weapon.position = PIVOT.get_node("weapon_pos").position
	PIVOT.add_child(new_weapon)
	
func _on_shooting_timer_timeout() -> void:
	can_shoot = true

func update_sensibility():
	MOUSE_SENSIBILITY = JsonOptionsSaving.options["controls"]["sensibility"] / SENSIBILITY_DENOMINATOR

func update_weapon_stats():
	if !PIVOT.has_node("blaster"):
		return
	weapon_stats = PIVOT.get_node("blaster").weapon_stats

func save_weapon():
	if !PIVOT.has_node("blaster"):
		return
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(PIVOT.get_node("blaster"), "position:z", -1 * Z_POS_TO_HIDE_WEAPON, 0.2)
	PIVOT.get_node("weapon_pos").position.z -= Z_POS_TO_HIDE_WEAPON
	await tween.finished

func take_out_weapon():
	if !PIVOT.has_node("blaster"):
		return
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(PIVOT.get_node("blaster"), "position:z", Z_POS_TO_HIDE_WEAPON, 0.2)
	PIVOT.get_node("weapon_pos").position.z += Z_POS_TO_HIDE_WEAPON
	await tween.finished

func add_camera_trauma(trauma_amount: float):
	CAMERA.add_trauma(trauma_amount)
	
func play_sfx_footsteps():
	var footsteps_time = FOOTSTEPS_TIME["running"] if is_running else FOOTSTEPS_TIME["crouching"] if is_crouching else FOOTSTEPS_TIME["walking"]
	await get_tree().create_timer(footsteps_time).timeout
	if is_moving and is_on_floor():
		SFX_FOOTSTEPS.play()
		add_camera_trauma(0.2)
	play_sfx_footsteps()
