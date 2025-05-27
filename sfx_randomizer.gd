extends Node

var min_amplify = -5.0
var max_amplify = 4.0

func _process(_delta: float) -> void:
	randomize_sfx_pitch()

func randomize_sfx_pitch():
	randomize()
	var sfx_bus = AudioServer.get_bus_index("Sfx")
	var effect = AudioServer.get_bus_effect(sfx_bus, 0)
	effect.volume_db = lerpf(min_amplify, max_amplify, randf())
