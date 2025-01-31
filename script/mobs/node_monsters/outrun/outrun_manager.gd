extends RefCounted
class_name OutrunManager

const START_POINT_DISTANCE: float = 10
const END_POINT_DISTANCE: float = 10

var isActive: bool = false

"""
Initializes the manager. Called by Game
"""
func ready() -> void:
	Game.room_opened.connect(_on_room_opened)

func _on_room_opened(_room: Room) -> void:
	pass


