extends MarginContainer

@onready var GRID_CONTAINER = $VBoxContainer/HBoxContainer/clip_control/Control/GridContainer
@onready var LEVELS_ARRAY = GRID_CONTAINER.get_children()
@onready var DIAMONDS_LABEL = %diamonds_label
@onready var COINS_LABEL = %coins_label

var NUM_GRIDS = 2
var current_grid = 1
var GRID_WIDTH = 540

func _ready() -> void:
	SaveLoadPlayerStats.load_player_stats()
	#GlobalDiamondsBool.diamonds = SaveLoadPlayerStats.player_stats["diamonds"]
	for box in LEVELS_ARRAY:
		unlock_levels_onready(box)
	update_coins_diamonds_indicator()
	
	UpdateResolution.update_resolution()

func _process(_delta: float) -> void:
	check_esc()
	
func check_esc():
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://main_menu_bg.tscn")
		
func _on_back_button_pressed():
	if current_grid > 1:
		change_grid(-1)

func _on_next_button_pressed():
	if current_grid < NUM_GRIDS:
		change_grid(1)

func unlock_levels_onready(box: Control):
	if box.level_num <= SaveLoadPlayerStats.player_stats["levels_unlocked"]:
		box.set_locked(false)
	elif box.level_num == SaveLoadPlayerStats.player_stats["levels_completed"] + 1:
		var wait_time = 0.4 if box.level_num == 1 else 0.6
		await get_tree().create_timer(wait_time).timeout
		SaveLoadPlayerStats.player_stats["levels_unlocked"] += 1
		box.unlock()
	   
func change_grid(arrow_pressed: int): #* -1 to go back, 1 to go forward
	current_grid += arrow_pressed
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(GRID_CONTAINER, "position:x", GRID_CONTAINER.position.x - (GRID_WIDTH * arrow_pressed), 0.5)

func _on_texture_button_button_up() -> void:
	get_tree().change_scene_to_file("res://main_menu_bg.tscn")

func update_coins_diamonds_indicator():
	COINS_LABEL.text = str(SaveLoadPlayerStats.player_stats["total_coins"])
	DIAMONDS_LABEL.text = str(SaveLoadPlayerStats.player_stats["total_diamonds"])
