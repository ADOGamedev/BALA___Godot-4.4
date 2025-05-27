extends Control

@onready var LABEL = $margin/HBoxContainer/Label
@onready var MARGIN = $margin
@onready var MARGIN_X_SIZE = MARGIN.size.x

func _ready() -> void:
    MARGIN.position.x = -1 * MARGIN_X_SIZE
    _start_three_dots_anim()
    
func indicate_saving():
    var timer = Timer.new()
    timer.process_mode = PROCESS_MODE_ALWAYS
    add_child(timer)
    timer.start(2.0)

    show_indicator()
    await timer.timeout
    hide_indicator()
    
func show_indicator():
    var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.tween_property(MARGIN, "position:x", 0, 0.4)

func hide_indicator():
    var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.tween_property(MARGIN, "position:x", -1 * MARGIN_X_SIZE, 0.4)

func _start_three_dots_anim():
    for i in range(3):
        LABEL.text += "."
        await get_tree().create_timer(0.2).timeout
    LABEL.text = "SAVING"
    await get_tree().create_timer(0.1).timeout
    _start_three_dots_anim()