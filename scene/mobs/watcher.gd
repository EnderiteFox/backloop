extends CharacterBody3D

@onready var watcherRaycast:RayCast3D = %watcher_raycast

func _process(delta: float) -> void:
	if watcherRaycast.is_seeing_player():
		Game.player.is_alive = false 
		
