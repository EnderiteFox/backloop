extends Node3D

const CAMERA_TRANSITION_TIME: float = 0.2

func _ready() -> void:
	%InteractionHitbox.interacted.connect(_on_interact)
	%AnimationPlayer.animation_finished.connect(func(animation): _on_fully_opened())

func _on_interact() -> void:
	%OpenCamera.make_current()
	%AnimationPlayer.play("Door/open")

func _on_fully_opened() -> void:
	%OpenCamera.clear_current()
	Game.player.position = %PlayerTeleport.global_position
	Game.player.rotation = %PlayerTeleport.global_rotation
	Game.player.camPivot.rotation.x = %OpenCamera.global_rotation.x
