extends Control

@onready var POPOUT_TEXT = %popout_text
@onready var POPOUT_LABEL = %popout_label
@onready var POPOUT_LABEL_Y_POS = %popout_container.position.y + %popout_container.get_theme_constant("margin_top")
@onready var POPOUT_LABEL_Y_SIZE = %popout_container.size.y - (%popout_container.get_theme_constant("margin_top") * 2)
@onready var POPOUT_LABEL_LINE_SEPARATION = %popout_label.get_theme_constant("line_separation")
@onready var HIDDEN_NOTIFIER = $popout_text/hidded_notifier
@onready var SHOWN_NOTIFIER = $popout_text/shown_notifier

@onready var TIMER = $Timer

var Y_POS_TO_SHOW
@onready var Y_POS_TO_HIDE = POPOUT_TEXT.position.y

var YELLOW_COLOR = Color.hex(0xede84aff)
var YELLOW_HEX_CODE = "ede84aff"

var shown_notifier_visible = false
var hidden_notifier_visible = false

var is_showing = false
var is_hidding = false

@onready var tween : Tween

var global_delta : float = 1/60

var is_fast_popout_movement = false

func _ready() -> void:
	set_notifiers_positions()

func _process(delta: float) -> void:
	global_delta = delta
	check_hidding_showing()
	change_notifiers_pos()
	
func popout(text_to_show):
	TIMER.stop()
	if shown_notifier_visible:
		hide_popout(true) #* In case that the popout is already shown it will hide to change the text
		await SHOWN_NOTIFIER.screen_exited
	
	POPOUT_LABEL.text = "[center]" + text_to_show + "[/center]"
	Y_POS_TO_SHOW = get_distance_to_show_popout()
	show_popout()
	
	TIMER.start(3.5)
	await TIMER.timeout

	hide_popout()
	Y_POS_TO_HIDE = POPOUT_TEXT.position.y
	
func animate_popout(target_y, duration):
	tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(POPOUT_TEXT, "position:y", target_y, duration)
	await tween.finished

func show_popout(fast_showing: float = false):
	if get_tree().paused:
		return
	is_fast_popout_movement = fast_showing
	if !hidden_notifier_visible:
		is_showing = true
		POPOUT_TEXT.position.y -= 210.0 * global_delta * (2.5 if fast_showing else 1.0)
		await get_tree().process_frame
	else:
		is_showing = false
		
		
func hide_popout(fast_showing: float = false):
	if get_tree().paused:
		return
	is_fast_popout_movement = fast_showing
	if shown_notifier_visible:
		is_hidding = true
		POPOUT_TEXT.position.y += 210.0 * global_delta * (2.5 if fast_showing else 1.0)
		await get_tree().process_frame
	else:
		is_hidding = false

func check_hidding_showing():
	if is_hidding:
		hide_popout(is_fast_popout_movement)
	if is_showing:
		show_popout(is_fast_popout_movement)
	
func get_distance_to_show_popout():
	#? For me this line is very hard to understand
	return Y_POS_TO_HIDE - (POPOUT_LABEL.get_line_count() * (POPOUT_LABEL_Y_SIZE) + POPOUT_LABEL_Y_POS * 2 - POPOUT_LABEL_LINE_SEPARATION)
	
func set_notifiers_positions():
	HIDDEN_NOTIFIER.rect = Rect2(0, 5, %popout_container.size.x, %popout_container.size.y)
	SHOWN_NOTIFIER.rect = Rect2(0, 0, %popout_container.size.x, %popout_container.size.y)
	HIDDEN_NOTIFIER.position.y = %popout_container.size.y

func change_notifiers_pos():
	if POPOUT_LABEL.get_line_count() > 1:
		SHOWN_NOTIFIER.position.y = (POPOUT_LABEL.get_theme_font_size("bold_font_size")
		 							+ POPOUT_LABEL.get_theme_constant("line_separation") - 75)
		HIDDEN_NOTIFIER.position.y = (%popout_container.size.y 
									+ POPOUT_LABEL.get_theme_font_size("bold_font_size")
		 							+ POPOUT_LABEL.get_theme_constant("line_separation") - 25)
	else:
		SHOWN_NOTIFIER.position.y = 0
		HIDDEN_NOTIFIER.position.y = %popout_container.size.y

func _on_shown_notifier_screen_entered() -> void:
	shown_notifier_visible = true
	
func _on_shown_notifier_screen_exited() -> void:
	shown_notifier_visible = false
	
func _on_hidded_notifier_screen_entered() -> void:
	hidden_notifier_visible = true
	
func _on_hidded_notifier_screen_exited() -> void:
	hidden_notifier_visible = false
