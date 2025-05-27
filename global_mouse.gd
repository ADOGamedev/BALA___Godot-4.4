extends Node

var MOUSE_TEXTURE = "res://assets/ui/mouse.png"
var IBEAM_MOUSE_TEXTURE = "res://assets/ui/mouse_to_writte.png"

func _ready() -> void:
    Input.set_custom_mouse_cursor(load(MOUSE_TEXTURE), Input.CursorShape.CURSOR_ARROW, Vector2(0, 0))
    Input.set_custom_mouse_cursor(load(IBEAM_MOUSE_TEXTURE), Input.CursorShape.CURSOR_IBEAM, Vector2(16, 32))
    