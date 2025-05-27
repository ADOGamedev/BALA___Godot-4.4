extends Node

var json_path = "user://options.json"
var options: Dictionary = {
	"audio": {
		"general": 100.0,
		"music": 100.0,
		"sfx": 100.0
	},
	"video": {
		"saturation": 100.0,
		"resolution": -1,
		"fullscreen": false
	},
	"performance": {
		"quality_level": 0,
		"sdfgi": true,
		"max_fps": 60.0,
		"show_fps": false,
		"vsync": true
	},
	"controls": {
		"sensibility": 50.0,
		"key_bindings": {
			"forward": KEY_W,
			"back": KEY_S,
			"left": KEY_A,
			"right": KEY_D,
			"jump": KEY_SPACE,
			"run": KEY_CTRL,
			"crouch": KEY_SHIFT,
			"shoot": MOUSE_BUTTON_LEFT,
			"change_weapon": KEY_E
		}
	}
}

func _ready() -> void:
	if !FileAccess.file_exists(json_path):
		save_options()
	load_options()
	GlobalSaturation.create_env()
	GlobalSaturation.set_saturation(options["video"]["saturation"])

func save_options():
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(options))
	file.close()

func load_options():
	var file = FileAccess.open(json_path, FileAccess.READ)
	if FileAccess.file_exists(json_path):
		options = JSON.parse_string(file.get_as_text())
		file.close()

func set_value(dictionary: String, key: String, value):
	options[dictionary][key] = value
	save_options()

func set_control(key: String, keycode: int):
	options["controls"]["key_bindings"][key] = keycode
	save_options()
