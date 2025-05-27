extends Control

@onready var FPS_LABEL = $fps_label

func _process(_delta: float) -> void:
	update_fps_label()

func update_fps_label():
	FPS_LABEL.visible = JsonOptionsSaving.options["performance"]["show_fps"]
	FPS_LABEL.text = "FPS: %.1f " % Engine.get_frames_per_second()
