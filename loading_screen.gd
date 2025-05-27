extends Control

@onready var progress: Array
@onready var scene_load_status: int
@onready var LOADING_LABEL = %loading_label

var LOADING_INTERVAL = 0.15

func _ready() -> void:
	ResourceLoader.load_threaded_request(GlobalSceneChange.change_scene)
	start_loading_animation()

func _process(_delta: float) -> void:
	if scene_load_status != ResourceLoader.THREAD_LOAD_LOADED:
		update_scene_load_status()

func update_loading_label_text():
	if LOADING_LABEL.text != "LOADING...":
		LOADING_LABEL.text = LOADING_LABEL.text + "."
	else:
		LOADING_LABEL.text = "LOADING"

func start_loading_animation():
	update_loading_label_text()
	await get_tree().create_timer(LOADING_INTERVAL).timeout
	start_loading_animation()

func update_scene_load_status():
	scene_load_status = ResourceLoader.load_threaded_get_status(GlobalSceneChange.change_scene, progress) 
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().call_deferred("change_scene_to_packed", ResourceLoader.load_threaded_get(GlobalSceneChange.change_scene))
