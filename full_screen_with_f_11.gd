extends Node

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
func _input(event: InputEvent) -> void:
	var toggled_on = true if DisplayServer.window_get_mode(0) != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	var window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_MAXIMIZED
	if event is InputEventKey:
		if event.keycode == KEY_F11 and event.pressed:
			DisplayServer.window_set_mode(window_mode)
			JsonOptionsSaving.set_value("video", "fullscreen", toggled_on)
