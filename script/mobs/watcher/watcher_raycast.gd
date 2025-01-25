extends RayCast3D

var death_is_coming = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.target_position = Game.player.position
	death_is_coming = is_seeing_player()
	
func is_seeing_player():
	if get_collider() is Player:
		return true
	return false
	

	
	
