class_name TheWatcherRaycast
extends RayCast3D

signal saw_player

func _physics_process(_delta: float) -> void:
	self.target_position = to_local(Game.player.camera.global_position)
	
	if get_collider() is Player && self.enabled:
		self.enabled = false
		saw_player.emit()
