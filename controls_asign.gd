extends Control

@onready var controls_buttons = {
	"forward": %forward_button,
	"back": %back_button,
	"left": %left_button,
	"right": %right_button,
	"jump": %jump_button,
	"run": %run_button,
	"crouch": %crouch_button,
	"shoot": %shoot_button,
	"change_weapon": %change_weapon_button
}

var button_pressed = {
	"forward": false,
	"back": false,
	"left": false,
	"right": false,
	"jump": false,
	"run": false,
	"crouch": false,
	"shoot": false,
	"change_weapon": false,
	"waiting": false
}

var default_controls = {
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

var change_controls = false

func _ready() -> void:
	asign_all_controls(JsonOptionsSaving.options["controls"]["key_bindings"])

func asign_all_controls(dictionary: Dictionary):
	for key in controls_buttons:
		var input_event_key
		var new_text = (OS.get_keycode_string(dictionary[key])).to_upper()
		if dictionary[key] >= MOUSE_BUTTON_LEFT and dictionary[key] <= MOUSE_BUTTON_XBUTTON2:
			input_event_key = InputEventMouseButton.new()
			input_event_key.button_index = dictionary[key]
			match input_event_key.button_index:
				MOUSE_BUTTON_LEFT:
					new_text = "LEFT CLICK"
				MOUSE_BUTTON_RIGHT:
					new_text = "RIGHT CLICK"
				MOUSE_BUTTON_MIDDLE:
					new_text = "MOUSE WHEEL"
				MOUSE_BUTTON_XBUTTON1:
					new_text = "BUTTON 1"
				MOUSE_BUTTON_XBUTTON2:
					new_text = "BUTTON 2"
		else:
			input_event_key = InputEventKey.new()
			input_event_key.keycode = dictionary[key]
		change_input_map(key, input_event_key)
		controls_buttons[key].text = new_text
		JsonOptionsSaving.set_control(key, dictionary[key])

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and button_pressed["waiting"]:
		button_pressed["waiting"] = false
		asign_new_control(event)

func asign_new_control(event):
	change_controls = true
	var saved_controls = JsonOptionsSaving.options["controls"]["key_bindings"]
	var event_keycode = event.keycode if event is InputEventKey else event.button_index
	var current_button_pressed
	var controls_repeated = 0
	for button in button_pressed:
		if button != "waiting" and button_pressed[button]:
			current_button_pressed = button
	for keycode in saved_controls:
		if controls_repeated == 0:
			if keycode != current_button_pressed:
				if event_keycode == saved_controls[keycode]:
					var confirmation = owner.get_node("repeated_controls_advise")
					controls_repeated += 1
					confirmation.visible = true
					confirmation.shacky_effect()
					await confirmation.get_node("Panel/VBoxContainer/HBoxContainer/exit_button").button_down
					if !change_controls:
						return

	var new_text
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				new_text = "LEFT CLICK"
			MOUSE_BUTTON_RIGHT:
				new_text = "RIGHT CLICK"
			MOUSE_BUTTON_MIDDLE:
				new_text = "MOUSE WHEEL"
			MOUSE_BUTTON_XBUTTON1:
				new_text = "BUTTON 1"
			MOUSE_BUTTON_XBUTTON2:
				new_text = "BUTTON 2"
	else:
		new_text = (OS.get_keycode_string(event.keycode)).to_upper()
	for key in button_pressed:
		if event.is_pressed() and button_pressed[key] and key != "waiting":
			change_input_map(key, event)
			controls_buttons[key].text = new_text
			button_pressed[key] = false
			if event is InputEventMouseButton:
				JsonOptionsSaving.set_control(key, event.button_index)
			else:
				JsonOptionsSaving.set_control(key, event.keycode)

func change_input_map(input_action_name: String, input_event: InputEvent):
	InputMap.action_erase_events(input_action_name)
	InputMap.action_add_event(input_action_name, input_event)

func _on_restart_controls_button_pressed() -> void:
	var confirmation = owner.get_node("popout_confirmation")
	confirmation.visible = true
	confirmation.shacky_effect()
	
func _on_forward_button_pressed() -> void:
	button_pressed["forward"] = true
	button_pressed["waiting"] = true

func _on_back_button_pressed() -> void:
	button_pressed["back"] = true
	button_pressed["waiting"] = true

func _on_left_button_pressed() -> void:
	button_pressed["left"] = true
	button_pressed["waiting"] = true

func _on_right_button_pressed() -> void:
	button_pressed["right"] = true
	button_pressed["waiting"] = true

func _on_jump_button_pressed() -> void:
	button_pressed["jump"] = true
	button_pressed["waiting"] = true

func _on_run_button_pressed() -> void:
	button_pressed["run"] = true
	button_pressed["waiting"] = true

func _on_crouch_button_pressed() -> void:
	button_pressed["crouch"] = true
	button_pressed["waiting"] = true

func _on_shoot_button_pressed() -> void:
	button_pressed["shoot"] = true
	button_pressed["waiting"] = true

func _on_change_weapon_button_pressed() -> void:
	button_pressed["change_weapon"] = true
	button_pressed["waiting"] = true
