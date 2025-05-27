extends Node

var previous_resolution
var current_resolution
	
func _process(delta: float) -> void:
	if current_resolution != null:
		previous_resolution = current_resolution
	current_resolution = DisplayServer.window_get_size()

func update_resolution():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(previous_resolution)
