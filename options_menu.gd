extends Control

signal windy_trees_toggled

@onready var RESOLUTION_MENU_BUTTON = %resolution_menu_button
@onready var QUALITY_LEVEL_MENU_BUTTON = %quality_level_menu_button
@onready var MAX_FPS_SLIDER = %max_fps_slider
@onready var OPTION_BUTTONS = %options_buttons.get_children()
@onready var MENUS = {
	"performance": %perfomance,
	"video": %video,
	"audio": %audio,
	"controls": %controls,
}
@onready var CONTROLS_ASIGN_NODE = %controls_asign

var resolutions = [
  	# 4:3
	Vector2i(1024, 768),  
	Vector2i(1600, 1200),  

	# 16:9
	Vector2i(1280, 720),  
	Vector2i(1600, 900), 
	Vector2i(1920, 1080),
	Vector2i(2560, 1440), 
	Vector2i(3840, 2160), 

	# 16:10
	Vector2i(1280, 800),
	Vector2i(1920, 1200),

	# 21:9
	Vector2i(2560, 1080),
	Vector2i(3440, 1440)
]
var is_maximized = false
@onready var previous_monitor = DisplayServer.window_get_current_screen()
var previous_quality_index = 0

@onready var tree_shader = preload("res://assets/shaders/pine.tres")
@onready var pine_shader = preload("res://assets/shaders/tree.tres")

var SLIDER_STYLES = {
	"slider_disabled" : "res://assets/ui/slider_dissabled.tres",
	"grabber_area_disabled" : "res://assets/ui/slider_grabber_area_dissabled.tres",
	"grabber_disabled" : "res://assets/ui/slider_grabber_dissabled.png",
	"slider_enabled" : "res://assets/ui/slider.tres",
	"grabber_area_enabled" : "res://assets/ui/slider_grabber_area.tres",
	"grabber_enabled" : "res://assets/ui/slider_grabber.png"
}

func _ready() -> void:
	load_all_options()

func _process(_delta: float) -> void:
	$control_change_confirm.visible = CONTROLS_ASIGN_NODE.button_pressed["waiting"]
	previous_quality_index = QUALITY_LEVEL_MENU_BUTTON.selected
	check_fullsreen()
	check_monitor_vsync()
	check_manual_resolution_change()

func _on_audio_pressed() -> void:
	change_option_buttons(0)
	set_menu_visibility("audio")

func _on_video_pressed() -> void:
	change_option_buttons(1)
	set_menu_visibility("video")

func _on_performance_pressed() -> void:
	change_option_buttons(2)
	set_menu_visibility("performance")

func _on_controlls_pressed() -> void:
	change_option_buttons(3)
	set_menu_visibility("controls")

func set_menu_visibility(active_menu: String):
	for menu in MENUS.keys():
		MENUS[menu].visible = (menu == active_menu)

func change_option_buttons(pressed_button_index: int):
	for index in range(OPTION_BUTTONS.size()):
		OPTION_BUTTONS[index].button_pressed = (index == pressed_button_index)

func _on_back_button_pressed() -> void:
	visible = false

func load_all_options():
	%general_slider.value = JsonOptionsSaving.options["audio"]["general"]
	%music_slider.value = JsonOptionsSaving.options["audio"]["music"]
	%sfx_slider.value = JsonOptionsSaving.options["audio"]["sfx"]

	check_fullsreen()
	set_resolution(RESOLUTION_MENU_BUTTON.selected)
	%saturation_slider.value = JsonOptionsSaving.options["video"]["saturation"]
	%fullscreen_check.button_pressed = JsonOptionsSaving.options["video"]["fullscreen"]
	for resolution in resolutions:
		%resolution_menu_button.get_popup().add_item(" " + str(resolution.x) + ", " + str(resolution.y))

	%show_fps_check_button.button_pressed = JsonOptionsSaving.options["performance"]["show_fps"]
	%vsync_check_button.button_pressed = JsonOptionsSaving.options["performance"]["vsync"]
	%quality_level_menu_button.selected = JsonOptionsSaving.options["performance"]["quality_level"]
	if JsonOptionsSaving.options["performance"]["max_fps"] == 0:
		MAX_FPS_SLIDER.value = MAX_FPS_SLIDER.max_value
	else:
		MAX_FPS_SLIDER.value = JsonOptionsSaving.options["performance"]["max_fps"]
	%sdfgi_button.button_pressed = JsonOptionsSaving.options["performance"]["sdfgi"]
	turn_on_vsync(JsonOptionsSaving.options["performance"]["vsync"])
	%sensibility_slider.value = JsonOptionsSaving.options["controls"]["sensibility"]

func change_slider_value(value: float, category: String, subcategory: String, label: Label, unit: String):
	JsonOptionsSaving.set_value(category, subcategory, value)
	label.text = " " + str(int(value)) + unit

#* -----------------------AUDIO-----------------------
func _on_general_slider_value_changed(value:float) -> void:
	change_slider_value(value, "audio", "general", %general_label, "%")
	var general_bus = AudioServer.get_bus_index("Master")
	var volume_db
	if value <= 100:
		volume_db = lerp(-50, 0, value/100)
	else:
		volume_db = lerp(0, 6, value/100)
	AudioServer.set_bus_volume_db(general_bus, volume_db)
	
func _on_music_slider_value_changed(value:float) -> void:
	change_slider_value(value, "audio", "music", %music_label, "%")
	var music_bus = AudioServer.get_bus_index("Music")
	var volume_db
	if value <= 100:
		volume_db = lerp(-80, 0, value/100)
	else:
		volume_db = lerp(0, 6, value/100)
	AudioServer.set_bus_volume_db(music_bus, volume_db)

func _on_sfx_slider_value_changed(value:float) -> void:
	change_slider_value(value, "audio", "sfx", %sfx_label, "%")
	var sfx_bus = AudioServer.get_bus_index("Sfx")
	var volume_db
	if value <= 100:
		volume_db = lerp(-80, 0, value/100)
	else:
		volume_db = lerp(0, 6, value/100)
	AudioServer.set_bus_volume_db(sfx_bus, volume_db)

#* -----------------------VIDEO-----------------------
func check_fullsreen():
	var fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	is_maximized = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED or
				DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if is_maximized:
		%resolution_menu_button.selected = -1
	JsonOptionsSaving.options["video"]["fullscreen"] = fullscreen
	%fullscreen_check.button_pressed = JsonOptionsSaving.options["video"]["fullscreen"]

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	var window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(window_mode)
	JsonOptionsSaving.set_value("video", "fullscreen", toggled_on)

func _on_resolution_button_item_selected(index:int) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	set_resolution(index)

func check_manual_resolution_change():
	if %resolution_menu_button.selected == -1:
		return
	if get_viewport().size != Vector2i(resolutions[%resolution_menu_button.selected]):
		%resolution_menu_button.selected = -1

func set_resolution(resolution_index: int):
	DisplayServer.window_set_size(resolutions[resolution_index])
	JsonOptionsSaving.set_value("video", "resolution", resolution_index)

func _on_saturation_slider_value_changed(value:float) -> void:
	GlobalSaturation.set_saturation(value)
	change_slider_value(value, "video", "saturation", %saturation_label, "%")

#* -----------------------PERFORMANCE-----------------------
func _on_vsync_check_button_toggled(toggled_on:bool) -> void:
	JsonOptionsSaving.set_value("performance", "vsync", toggled_on)
	turn_on_vsync(toggled_on)

func turn_on_vsync(vsync_enabled: bool):
	change_fps_slider_style(vsync_enabled)
	change_vsync(vsync_enabled)
	
func change_vsync(vsync_enabled: bool):
	var vsync_mode = 1 if vsync_enabled else 0
	DisplayServer.window_set_vsync_mode(vsync_mode)
	if vsync_enabled:
		MAX_FPS_SLIDER.value = DisplayServer.screen_get_refresh_rate(DisplayServer.window_get_current_screen())
	else:
		if JsonOptionsSaving.options["performance"]["max_fps"] == 0:
			MAX_FPS_SLIDER.value = MAX_FPS_SLIDER.max_value
		else:
			MAX_FPS_SLIDER.value = JsonOptionsSaving.options["performance"]["max_fps"]
	Engine.max_fps = MAX_FPS_SLIDER.value

func check_monitor_vsync():
	if DisplayServer.window_get_vsync_mode() == 0:
		return
	if DisplayServer.window_get_current_screen() != previous_monitor:
		change_vsync(true)
		previous_monitor = DisplayServer.window_get_current_screen()

func change_fps_slider_style(vsync_enabled: bool):
	var slider_style = SLIDER_STYLES["slider_disabled"] if vsync_enabled else SLIDER_STYLES["slider_enabled"]
	var grabber_area = SLIDER_STYLES["grabber_area_disabled"] if vsync_enabled else SLIDER_STYLES["grabber_area_enabled"]
	var grabber_icon = SLIDER_STYLES["grabber_disabled"] if vsync_enabled else SLIDER_STYLES["grabber_enabled"]
	var slider_mouse_filter = MOUSE_FILTER_IGNORE if vsync_enabled else MOUSE_FILTER_STOP
	MAX_FPS_SLIDER.add_theme_stylebox_override("slider", load(slider_style))
	MAX_FPS_SLIDER.add_theme_stylebox_override("grabber_area", load(grabber_area))
	MAX_FPS_SLIDER.add_theme_icon_override("grabber", load(grabber_icon))
	MAX_FPS_SLIDER.mouse_filter = slider_mouse_filter

func _on_show_fps_button_toggled(toggled_on:bool) -> void:
	JsonOptionsSaving.set_value("performance", "show_fps", toggled_on)

func _on_max_fps_slider_value_changed(value:int) -> void:
	if !JsonOptionsSaving.options["performance"]["vsync"]:
		if value == MAX_FPS_SLIDER.max_value:
			value = 0
		Engine.max_fps = value
	change_slider_value(value, "performance", "max_fps", %max_fps_label, "")
	if value == 0:
		%max_fps_label.text = " +300"

func _on_quality_level_button_item_selected(index:int) -> void:
	var previos_index = previous_quality_index
	var confirmation = $change_quality_level_confirmation
	var selected_quality = ("high" if index == 0 else 
							"medium" if index == 1 else 
							"low")
	#confirmation.visible = true
	#confirmation.shacky_effect()

	#QUALITY_LEVEL_MENU_BUTTON.selected = previos_index
	#await confirmation.get_node("Panel/VBoxContainer/HBoxContainer/exit_button").pressed
	QUALITY_LEVEL_MENU_BUTTON.selected = index
	change_quality_level(selected_quality)
	JsonOptionsSaving.set_value("performance", "quality_level", index)

func change_quality_level(quality: String):
	var env = load("res://level_env.tres") as Environment
	if quality == "high":
		env.ssao_enabled = true
		env.ssil_enabled = true
		env.sdfgi_cascades = 5
		#ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 4096)
		#ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 4)

	elif quality == "medium":
		env.ssao_enabled = false
		env.ssil_enabled = false
		env.sdfgi_cascades = 4
		#ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 4096)
		#ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 2)
	
	else: 
		env.ssao_enabled = false
		env.ssil_enabled = false
		env.sdfgi_cascades = 2
		#ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 2048)
		#ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality", 0)

func _on_sdfgi_button_toggled(toggled_on: bool) -> void:
	var env = load("res://level_env.tres") as Environment
	env.sdfgi_enabled = toggled_on
	JsonOptionsSaving.set_value("performance", "sdfgi", toggled_on)
	
#* -----------------------CONTROLS-----------------------
func _on_sensibility_slider_value_changed(value:float) -> void:
	change_slider_value(value, "controls", "sensibility", %sensibility_label, "%")
