extends Node3D

@onready var PARTICLES: GeometryInstance3D = $particles
@export var enemy_scale : float = 1.0
@export var enemy_scene : PackedScene
var enemy : Node

@export var enemy_speed : float
@export var enemy_health : float
@export var enemy_damage : int

@export var enemy_outside_pos_add_multiplier := 1.41

var enemy_dead = false

func _ready() -> void:
	enemy = enemy_scene.instantiate()
	enemy.scale = Vector3(enemy_scale, enemy_scale, enemy_scale) / Vector3(2, 2, 2) #* Because for some reason it need to be the half, otherwise it's too big
	enemy.outside_pos_add *= enemy_outside_pos_add_multiplier
	enemy.position.y -= 1.41 * enemy.scale.x * 2.0
	$enemy.add_child(enemy)
	if enemy_speed != 0:
		enemy.SPEED = enemy_speed
	if enemy_health != 0:
		enemy.health = enemy_health
	if enemy_damage != 0:
		enemy.damage = enemy_damage
	enemy.PLAYER = owner.get_node("player")

func _process(_delta: float) -> void:
	if enemy == null:
		return
	if enemy.dead:
		return
	update_particles_position()
	check_death()
	check_enemy_dead_particles()

func _on_battle_triguer_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		if enemy == null:
			return
		if enemy.dead:
			return
		enemy.show_exclamation()
		await appear_tween()
		enemy.can_target_player = true
		enemy.current_state = enemy.State.HAS_APPEARED

func _on_battle_triguer_body_exited(body:Node3D) -> void:
	if body.is_in_group("player"):
		if enemy == null:
			return
		if enemy.dead:
			return
		enemy.can_target_player = false
		await leave_tween()
		if enemy == null:
			return
		if enemy.dead:
			return
		enemy.current_state = enemy.State.UNDERGROUND
		if enemy.is_in_group("fusil_enemies"):
			enemy.get_node("AnimationPlayer").play("untilt")

func check_enemy_dead_particles():
	if enemy.dead:
		return
	var is_quality_low = JsonOptionsSaving.options["performance"]["quality_level"] == 2 #* Low
	if is_instance_valid(enemy.BODY_PARTICLES):
		if !is_quality_low and enemy.dead:
			enemy.BODY_PARTICLES.visible = true
		else:
			enemy.BODY_PARTICLES.visible = false
		enemy.BODY_PARTICLES.emitting = !is_quality_low
	if is_instance_valid(enemy.HEAD_PARTICLES):
		if !is_quality_low and enemy.dead:
			enemy.BODY_PARTICLES.visible = true
		else:
			enemy.BODY_PARTICLES.visible = false
		enemy.HEAD_PARTICLES.emitting = !is_quality_low

func appear_tween():
	if !is_instance_valid(get_tree()):
		return
	enemy.current_state = enemy.State.APPEARING

	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.set_loops(1).set_parallel(false)
	tween.tween_property(PARTICLES, "transparency", 0.0, 0.2)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(enemy, "position:y", enemy.outside_pos - 0.39, 0.65)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(enemy, "position:y", enemy.outside_pos + 0.39, 0.2)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(enemy, "position:y", enemy.outside_pos, 0.2)
	tween.tween_property(PARTICLES, "transparency", 1.0, 0.2)
	await tween.finished

func leave_tween():
	if !is_instance_valid(get_tree()):
		return
	enemy.current_state = enemy.State.LEAVING

	if enemy.is_in_group("fusil_enemies"):
		enemy.current_state = enemy.State.UNDERGROUND
		enemy.get_node("AnimationPlayer").play("untilt")

	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops(1).set_parallel(false)
	tween.tween_property(PARTICLES, "transparency", 0.0, 0.2)
	tween.tween_property(enemy, "position:y", enemy.position.y + 0.39, 0.2)
	tween.tween_property(enemy, "position:y", enemy.outside_pos - 0.39, 0.2)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(enemy, "position:y", enemy.underground_pos, 0.65)
	tween.tween_property(PARTICLES, "transparency", 1.0, 0.2)
	await tween.finished

func update_particles_position():
	var y_pos = PARTICLES.position.y
	PARTICLES.position = enemy.position
	PARTICLES.position.y = y_pos

func check_death():
	if enemy.dead:
		return
	if enemy.health <= 0:
		owner.enemies_dead += 1
		if enemy.has_method("die"):
			enemy.die()
