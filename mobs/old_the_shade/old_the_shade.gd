class_name OldTheShade
extends RoomElement

var playerMoveTime: float = 0.0
var playerStillTime: float = 0.0

var triggered: bool = false
var enabled: bool = true

@onready var jumpscareScene: PackedScene = load("uid://du73na0nwumla")

func _ready() -> void:
	super._ready()
	%AnimationPlayer.play("idle")
	%PlayerSafeSpot.body_entered.connect(
		func(_body):
			if !triggered:
				self.queue_free()
				Game.oldTheShade.isActive = false
	)
	for door in room.doors:
		door.opened.connect(
			func():
				self.queue_free()
				Game.oldTheShade.isActive = false
		)

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
			
	set_enabled(to_local(Game.player.global_position).z < 0)
	
	if playerStillTime >= Game.oldTheShade.ACTIVE_TIME && Game.player.is_alive:
		despawn()
	if playerMoveTime >= Game.oldTheShade.LENIENCE_TIME && Game.player.is_alive:
		kill_player()


func despawn() -> void:
	Game.player.blackout(Game.oldTheShade.DESPAWN_BLACKOUT_TIME)
	Game.oldTheShade.isActive = false
	self.queue_free()

func kill_player() -> void:
	Game.player.is_alive = false
	get_tree().change_scene_to_packed(jumpscareScene)
	
func set_enabled(enable: bool) -> void:
	self.enabled = enable
	self.visible = enable
	%RayCast3D.enabled = enable
