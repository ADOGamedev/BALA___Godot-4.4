extends Node3D

var obtained_loot_file := ConfigFile.new()

@onready var CHEST = $level2/others/chest
@onready var PORTAL = %end_portal
@onready var POPOUT_TEXTS = $popouts_texts
@onready var PLAYER = $player
@onready var PAUSE_MENU = $pause_menu
@onready var LEVEL_COMPLETED_SCREEN = $level_completed_screen
@onready var MOVING_PLAT_FINAL = %moving_plat_final
@onready var MOVING_PLAT_FINAL_2 = %moving_plat_final_2
@onready var DEATH_SCREEN = $death_screen
@onready var UI = $ui

var level_num = 2
var enemies_dead = 0
var all_enemies_death = false
var obtained_coins = 0
var level_completed = false
var current_chest
var plat1_player_pos = ""
var plat2_player_pos = ""

func _ready() -> void:
	get_tree().paused = false
	JsonLootSavingLoading.set_obtained_loot_file_name(level_num)
	JsonLootSavingLoading.set_all_loot(self, level_num)
	update_directional_light()
	call_deferred("update_world_env")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	UpdateResolution.update_resolution()
		
func _process(_delta: float) -> void:
	update_directional_light()
	return_plat_final_to_player(MOVING_PLAT_FINAL)
	return_plat_final_to_player(MOVING_PLAT_FINAL_2)
	

func _unhandled_input(event: InputEvent) -> void:
	control_of_mouse_mode(event)

func control_of_mouse_mode(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		PAUSE_MENU.visible = true
		$ui.visible = false
		get_tree().paused = true

func _on_portal_area_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		if current_chest != null:
			obtained_coins += current_chest.items_left
			level_completed = true
			SaveLoadPlayerStats.player_stats["total_coins"] += current_chest.items_left
			$ui.update_coins_label()
		JsonLootSavingLoading.save_player_loot()
		if !all_enemies_death:
			return
		if SaveLoadPlayerStats.player_stats["levels_completed"] < 2:
			SaveLoadPlayerStats.player_stats["levels_completed"] = 2
		SaveLoadPlayerStats.save_player_stats()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		await LEVEL_COMPLETED_SCREEN.appear()
		LEVEL_COMPLETED_SCREEN.show_obtained_coins()

func _on_didnt_kill_enemies_area_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		if enemies_dead < 1 and PLAYER.velocity.x < 0:
			popout_enemy_warning()

func _on_didnt_kill_enemy_2_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		if enemies_dead < 4 and PLAYER.velocity.z > 0:
			popout_enemy_warning()
			
func popout_enemy_warning():
	var random_message : String
	var random_num = randi_range(1, 3)
	if random_num == 1:
		random_message = "You must kill all the enemies!!!"
	elif random_num == 2:
		random_message = "You forgot to kill an enemy!!!"
	else:
		random_message = "You skipped an enemy!!!"

	POPOUT_TEXTS.popout(random_message)

func _on_pickable_blaster_area_body_entered(body:Node3D) -> void:
	var changing_weapon_key = get_control_binding("change_weapon")
	if body.is_in_group("player"):
		POPOUT_TEXTS.popout("You got an other weapon!")
		await get_tree().create_timer(1.2).timeout
		POPOUT_TEXTS.popout("Press [color="+POPOUT_TEXTS.YELLOW_HEX_CODE+"]"+ changing_weapon_key +"[/color]" + " to change between weapons.")

func get_control_binding(control_name: String):
	var control = JsonOptionsSaving.options["controls"]["key_bindings"][control_name]
	var is_mouse_button = control > MOUSE_BUTTON_LEFT and control < MOUSE_BUTTON_XBUTTON2
	if is_mouse_button:
		match control:
			MOUSE_BUTTON_LEFT:
				control = "LEFT CLICK"
			MOUSE_BUTTON_RIGHT:
				control = "RIGHT CLICK"
			MOUSE_BUTTON_MIDDLE:
				control = "MOUSE WHEEL"
			MOUSE_BUTTON_XBUTTON1:
				control = "BUTTON 1"
			MOUSE_BUTTON_XBUTTON2:
				control = "BUTTON 2"
	else:
		control = OS.get_keycode_string(control).to_upper()
	return control

func show_dead_screen():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	UI.visible = false
	DEATH_SCREEN.show_death_screen()
	get_tree().paused = true

func return_plat_final_to_player(plat_to_return: Node3D):
	if plat_to_return.tweening:
		return
	if plat_to_return == MOVING_PLAT_FINAL:
		if plat_to_return.get_node("Path3D/PathFollow3D").progress_ratio == 1 and plat1_player_pos == "start":
			plat_to_return.can_move = true
		if plat_to_return.get_node("Path3D/PathFollow3D").progress_ratio == 0 and plat1_player_pos == "end":
			plat_to_return.can_move = true
	
	if plat_to_return == MOVING_PLAT_FINAL_2:
		if plat_to_return.get_node("Path3D/PathFollow3D").progress_ratio == 1 and plat2_player_pos == "start":
			plat_to_return.can_move = true
		if plat_to_return.get_node("Path3D/PathFollow3D").progress_ratio == 0 and plat2_player_pos == "end":
			plat_to_return.can_move = true

func update_world_env():
	var env = $WorldEnvironment.environment
	env.sdfgi_enabled = false
	await get_tree().process_frame
	env.sdfgi_enabled = JsonOptionsSaving.options["performance"]["sdfgi"]

func update_directional_light():
	var quality_level = JsonOptionsSaving.options["performance"]["quality_level"]
	if quality_level == 0:
		$DirectionalLight3D.directional_shadow_mode = 2
	elif quality_level == 1:
		$DirectionalLight3D.directional_shadow_mode = 2
	else:
		$DirectionalLight3D.directional_shadow_mode = 0
		
func _on_moving_platform_station_start_body_entered(body:Node3D) -> void:
	if !body.is_in_group("player"):
		return
	plat1_player_pos = "start"

func _on_moving_platform_station_end_body_entered(body:Node3D) -> void:
	if !body.is_in_group("player"):
		return
	plat1_player_pos = "end"

func _on_moving_platform2_station_start_body_entered(body:Node3D) -> void:
	if !body.is_in_group("player"):
		return
	plat2_player_pos = "start"

func _on_moving_platform2_station_end_body_entered(body:Node3D) -> void:
	if !body.is_in_group("player"):
		return
	plat2_player_pos = "end"
