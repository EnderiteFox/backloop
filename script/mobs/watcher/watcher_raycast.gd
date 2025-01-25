extends RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.target_position = Game.player.position
	if is_seeing_player():
		
		
	
	
func is_seeing_player():
	if get_collider() is Player:
		return true
	return false
	

	
	
