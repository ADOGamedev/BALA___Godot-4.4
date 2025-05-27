extends Control

@onready var WEAPON_MENU = $RadialMenuAdvanced
@onready var hovered_weapon = WEAPON_MENU.get_selected_child()
@onready var PLAYER = owner.get_node("player")

var current_available_weapons: Array
var selected_weapon
var closed = true
var tween_show : Tween
var tween_hide : Tween

func _ready() -> void:
	set_starting_conditions()
	add_new_weapon()

func _process(_delta: float) -> void:
	if PLAYER == null:
		PLAYER = owner.get_node("player")
		return
	current_available_weapons = PLAYER.available_weapons
	update_player_can_shoot()
	handle_visibility()
	if current_available_weapons.size() <= 1:
		return
	get_input()

func update_player_can_shoot():
	if !closed:
		PLAYER.can_shoot = false

func get_input():
	if Input.is_action_just_pressed("change_weapon"):
		show_menu()
		if tween_hide != null:
			tween_hide.stop()
	if Input.is_action_just_released("change_weapon"):
		hide_menu()
		if tween_show != null:
			tween_show.stop()

func handle_visibility():
	if closed:
		visible = false
	else:
		visible = true
		hovered_weapon = WEAPON_MENU.get_selected_child()

func add_new_weapon():
	if current_available_weapons.size() <= 1:
		return

	for element in WEAPON_MENU.get_children():
		WEAPON_MENU.remove_child(element)
	for blaster in current_available_weapons:
		add_texture_to_radial_menu(blaster)

func add_texture_to_radial_menu(blaster: String):
	var blaster_texture = load(blaster).instantiate().texture.duplicate()
	var texture_rect = TextureRect.new()

	texture_rect.texture = blaster_texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	WEAPON_MENU.add_child(texture_rect)

func set_starting_conditions():
	pivot_offset = size / 2
	scale = Vector2.ZERO
	current_available_weapons = PLAYER.available_weapons

func show_menu():
	closed = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	animate_menu(tween_show, 0.65, 0.575, 0.1, 0.2)

func hide_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	selected_weapon = hovered_weapon
	if current_available_weapons.size() > 1:
		PLAYER.switch_weapon_to(WEAPON_MENU.get_children().find(selected_weapon))

	await animate_menu(tween_hide, 0.65, 0.0, 0.1, 0.1)

	PLAYER.can_shoot = true
	closed = true
	return selected_weapon

func animate_menu(tween: Tween, start_scale: float, target_scale: float, duration1: float, duration2: float):
	tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_parallel(false)
	tween.tween_property(self, "scale", Vector2(start_scale, start_scale), duration1)
	tween.tween_property(self, "scale", Vector2(target_scale, target_scale), duration2)
	await tween.finished

func _on_radial_menu_advanced_selection_changed(new_selection:int) -> int:
	return new_selection
