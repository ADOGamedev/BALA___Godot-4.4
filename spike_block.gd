extends StaticBody3D

@export var damage : int
var player_on_spikes = false
@onready var PLAYER := owner.get_node("player")

func _physics_process(_delta: float) -> void:
	if player_on_spikes and PLAYER.is_invencible == false:
		PLAYER.take_damage(damage, -PLAYER.velocity.normalized(), 1.5, 0.9, false, 0.05)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_on_spikes = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_on_spikes = false
