extends Area3D

@export var damage : int

var shown_time := 2.0
var hidden_time := 1.0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	await get_tree().create_timer(rng.randf_range(0, 2)).timeout
	handle_show_hide_loop()

func show_spikes():
	$AnimationPlayer.play("show")
	$CollisionShape3D.disabled = false

func hide_spikes():
	$AnimationPlayer.play("hide")
	$CollisionShape3D.disabled = true

func handle_show_hide_loop():
	await get_tree().create_timer(shown_time).timeout
	hide_spikes()
	await get_tree().create_timer(hidden_time).timeout
	show_spikes()

	handle_show_hide_loop()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage, -body.velocity.normalized())


