extends RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	target_position = Game.player.global_position - self.global_position
		
func is_seeing_player():
	if get_collider() is Player:
		return true
	return false
	

	
	
