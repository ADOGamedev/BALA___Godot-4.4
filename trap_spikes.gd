extends Area3D

@export var damage : int
@export var custom_starting_delay: float = 0.0

var shown_time := 2.0
var hidden_time := 1.0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var delay = rng.randf_range(0, 2) if custom_starting_delay == 0.0 else custom_starting_delay
	await get_tree().create_timer(delay).timeout
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
		body.take_damage(damage, -body.velocity.normalized(), 1.5, 0.8, false, 0.05)


