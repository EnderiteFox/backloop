extends Node3D

func _ready() -> void:
	%InteractionHitbox.interacted.connect(_on_interact)

func _on_interact() -> void:
	%AnimationPlayer.play("Door/open")
