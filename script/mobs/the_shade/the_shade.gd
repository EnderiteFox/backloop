extends Node3D
class_name TheShade

var playerMoveTime: float = 0.0
var playerStillTime: float = 0.0

var triggered: bool = false

@onready var jumpscareScene: PackedScene = load("res://scene/mobs/the_shade/jumpscare.tscn")

func _ready() -> void:
	%AnimationPlayer.play("idle")

func _physics_process(delta: float) -> void:
	%RayCast3D.target_position = %RayCast3D.to_local(Game.player.camera.global_position)
	if %RayCast3D.get_collider() is Player:
		triggered = true
		%AnimationPlayer.play("seeing_player")
	
	if triggered:
		if Game.player.isMoving():
			playerMoveTime += delta
		else:
			playerStillTime += delta
	else:
		self.look_at(Game.player.camera.global_position)
	
	if playerStillTime >= Game.theShade.ACTIVE_TIME && Game.player.is_alive:
		despawn()
	if playerMoveTime >= Game.theShade.LENIENCE_TIME && Game.player.is_alive:
		kill_player()


func despawn() -> void:
	Game.player.blackout(Game.theShade.DESPAWN_BLACKOUT_TIME)
	Game.theShade.isActive = false
	self.queue_free()

func kill_player() -> void:
	Game.player.is_alive = false
	get_tree().change_scene_to_packed(jumpscareScene)
