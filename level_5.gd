extends Node3D

var obtained_loot_file := ConfigFile.new()

#@onready var CHEST = %final_chest
#@onready var PORTAL = %end_portal
@onready var POPOUT_TEXTS = $popouts_texts
@onready var PLAYER = $player
@onready var PAUSE_MENU = $pause_menu
@onready var LEVEL_COMPLETED_SCREEN = $level_completed_screen
@onready var DEATH_SCREEN = $death_screen
@onready var UI = $ui

@export var level_num = 5
var enemies_dead = 0
var all_enemies_death = false
var obtained_coins = 0
var level_completed = false
var current_chest

func _ready() -> void:
	get_tree().paused = false
	JsonLootSavingLoading.set_obtained_loot_file_name(level_num)
	JsonLootSavingLoading.set_all_loot(self, level_num)
	update_directional_light()
	call_deferred("update_world_env")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	UpdateResolution.update_resolution()

#func _process(_delta: float) -> void:
	#if enemies_dead == 7:
		#all_enemies_death = true
		
	#if all_enemies_death:
		#if CHEST.locked:
			#CHEST.can_unlock = true
		#PORTAL.turn_on_portal(true)

func _unhandled_input(event: InputEvent) -> void:
	control_of_mouse_mode(event)

func control_of_mouse_mode(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		PAUSE_MENU.visible = true
		UI.visible = false
		get_tree().paused = true

func show_dead_screen():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	UI.visible = false
	DEATH_SCREEN.show_death_screen()
	get_tree().paused = true

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

func _on_portal_area_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		if current_chest != null:
			if current_chest.ITEM.instantiate().is_in_group("coins"):
				obtained_coins += current_chest.items_left
				level_completed = true
				SaveLoadPlayerStats.player_stats["total_coins"] += current_chest.items_left
				UI.update_coins_label()
		JsonLootSavingLoading.save_player_loot()
		if !all_enemies_death:
			return
		if SaveLoadPlayerStats.player_stats["levels_completed"] < 4:
			SaveLoadPlayerStats.player_stats["levels_completed"] = 4
		SaveLoadPlayerStats.save_player_stats()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		await LEVEL_COMPLETED_SCREEN.appear()
		LEVEL_COMPLETED_SCREEN.show_obtained_coins()
		
