extends HSlider

@onready var PRESSED_GRABBER_TEXTURE = preload("res://assets/ui/slider_grabber_pressed.png")
@onready var HOVERED_GRABBER_TEXTURE = preload("res://assets/ui/slider_grabber_highlight.png")

#? Why do I have to do this manually, why does godot not have options for this >:(
func _on_mouse_exited() -> void:
	if !Input.is_action_pressed("shoot"):
		release_focus()

func _on_drag_ended(_value_changed:bool) -> void:
	release_focus()
	add_theme_icon_override("grabber_highlight", HOVERED_GRABBER_TEXTURE)

func _on_drag_started() -> void:
	add_theme_icon_override("grabber_highlight", PRESSED_GRABBER_TEXTURE)
	
