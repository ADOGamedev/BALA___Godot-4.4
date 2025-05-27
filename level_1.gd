extends Node3D

@onready var PLAYER = $player
@onready var PLAYER_PIVOT = $player/pivot
@onready var POPOUT_TEXTS = $popouts_texts
@onready var MARIONETTES_ENEMIES = $"tutorial_level/enemies_marionettes".get_children()
@onready var CHEST = $chest
@onready var PAUSE_MENU = $pause_menu
@onready var LEVEL_COMPLETED_SCREEN = $level_completed_screen
@onready var PORTAL = %end_portal

var level_num = 1
var GREY_PORTAL_COLOR = 0x8c8c8cff
var PURPLE_PORTAL_COLOR = 0x8b00ffff
var player_got_weapon = false
var all_marionettes_dead = false
var started = true
var blaster_disappeared = false
var obtained_coins = 0
var level_completed = false
var current_chest

var are_marionettes_setup = false

func _ready() -> void:
	JsonLootSavingLoading.set_obtained_loot_file_name(level_num)
	JsonLootSavingLoading.set_all_loot(self, level_num)
	update_directional_light()
	call_deferred("update_world_env")
	
	var basic_movement_keys = get_control_binding("forward")
	basic_movement_keys += " " + get_control_binding("back")
	basic_movement_keys += " " + get_control_binding("left")
	basic_movement_keys += " " + get_control_binding("right")
	POPOUT_TEXTS.popout("Press [color="+POPOUT_TEXTS.YELLOW_HEX_CODE+"]"+ basic_movement_keys +"[/color]" + " to move.")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	UpdateResolution.update_resolution()
	
func _process(_delta: float) -> void:
	update_directional_light()
	if !has_node("pickable_blaster") and !blaster_disappeared:
		blaster_disappeared = true
		setup_marionettes()
		player_got_weapon = true
		return

	for marionette in MARIONETTES_ENEMIES:
		if abs(marionette.rotation_degrees.x) < 1.0 and abs(marionette.rotation_degrees.x) > 0.0:
			are_marionettes_setup = true

	if player_got_weapon:
		check_marionettes_death()

	if all_marionettes_dead:
		PORTAL.turn_on_portal(true)

func setup_marionettes():
	for marionette in MARIONETTES_ENEMIES:
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(marionette, "rotation_degrees:x", 0.0, 1)

func player_got_weapon_messages():
	var shooting_key = get_control_binding("shoot")
	POPOUT_TEXTS.popout("You got a weapon!")
	await get_tree().create_timer(1.2).timeout
	POPOUT_TEXTS.popout("Try to shoot those targets with [color="+POPOUT_TEXTS.YELLOW_HEX_CODE+"]"+ shooting_key +"[/color]" + ".")

func check_marionettes_death():
	if all_marionettes_dead or !are_marionettes_setup:
		return
	var marionettes_dead = 0
	for marionette in MARIONETTES_ENEMIES:
		if abs(marionette.rotation_degrees.x) >= 89:
			marionettes_dead += 1
	if marionettes_dead >= 3:
		all_marionettes_dead = true
	if marionettes_dead == MARIONETTES_ENEMIES.size() and SaveLoadPlayerStats.player_stats["levels_completed"] < 1:
		POPOUT_TEXTS.popout("Well done! You finished the tutorial.")
		all_marionettes_dead = true
		CHEST.can_unlock = true

func _unhandled_input(event: InputEvent) -> void:
	control_of_mouse_mode(event)

func control_of_mouse_mode(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		PAUSE_MENU.visible = true
		$ui.visible = false
		get_tree().paused = true

func _on_jump_body_entered(body:Node3D) -> void:
	var jumping_key = get_control_binding("jump")
	if body.is_in_group("player"):
		POPOUT_TEXTS.popout("Press [color="+POPOUT_TEXTS.YELLOW_HEX_CODE+"]"+ jumping_key +"[/color]" + " to jump!")

func _on_crouch_body_entered(body:Node3D) -> void:
	var crouching_key = get_control_binding("crouch")
	if body.is_in_group("player"):
		POPOUT_TEXTS.popout("You can crouch with [color="+POPOUT_TEXTS.YELLOW_HEX_CODE+"]"+ crouching_key +"[/color]" + ".")

func _on_run_body_entered(body:Node3D) -> void:
	var running_key = get_control_binding("run")
	if body.is_in_group("player"):
		POPOUT_TEXTS.popout("What a long path! Press [color="+POPOUT_TEXTS.YELLOW_HEX_CODE+"]"+ running_key +"[/color]" + " to run.")

func _on_portal_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if current_chest != null:
			obtained_coins += current_chest.items_left
			level_completed = true
			SaveLoadPlayerStats.player_stats["total_coins"] += current_chest.items_left
			$ui.update_coins_label()
		GlobalLootSavingLoading.save()
		JsonLootSavingLoading.save_player_loot()
		if !all_marionettes_dead:
			return
		if SaveLoadPlayerStats.player_stats["levels_completed"] < 1:
			SaveLoadPlayerStats.player_stats["levels_completed"] = 1
		SaveLoadPlayerStats.save_player_stats()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		await LEVEL_COMPLETED_SCREEN.appear()
		LEVEL_COMPLETED_SCREEN.show_obtained_coins()

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		blaster_disappeared = true
		await player_got_weapon_messages()
		setup_marionettes()
		player_got_weapon = true

func get_control_binding(control_name: String):
	var control = JsonOptionsSaving.options["controls"]["key_bindings"][control_name]
	var is_mouse_button = control > MOUSE_BUTTON_LEFT and control < MOUSE_BUTTON_XBUTTON2
	var text_to_return = ""
	if is_mouse_button:
		match control:
			MOUSE_BUTTON_LEFT:
				text_to_return = "LEFT CLICK"
			MOUSE_BUTTON_RIGHT:
				text_to_return = "RIGHT CLICK"
			MOUSE_BUTTON_MIDDLE:
				text_to_return = "MOUSE WHEEL"
			MOUSE_BUTTON_XBUTTON1:
				text_to_return = "BUTTON 1"
			MOUSE_BUTTON_XBUTTON2:
				text_to_return = "BUTTON 2"
	else:
		text_to_return = OS.get_keycode_string(control).to_upper()
	return text_to_return

func update_world_env():
	var env = $WorldEnvironment.environment
	env.sdfgi_enabled = false
	await get_tree().process_frame
	env.sdfgi_enabled = JsonOptionsSaving.options["performance"]["sdfgi"]

func update_directional_light():
	var quality_level = JsonOptionsSaving.options["performance"]["quality_level"]
	var directional_shadow_mode = $DirectionalLight3D.directional_shadow_mode
	if quality_level == 0:
		if directional_shadow_mode != 2:
			$DirectionalLight3D.directional_shadow_mode = 2
	elif quality_level == 1:
		if directional_shadow_mode != 2:
			$DirectionalLight3D.directional_shadow_mode = 2
	else:
		if directional_shadow_mode != 0:
			$DirectionalLight3D.directional_shadow_mode = 0
