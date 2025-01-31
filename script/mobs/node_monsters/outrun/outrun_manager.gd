extends Object
class_name OutrunManager

var isActive: bool = false

func _ready() -> void:
	Game.room_opened.connect(_on_room_opened)

func _on_room_opened(_room: Room) -> void:
	pass

func _get_path_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	var currentRoom: Room = Game.roomGenerator.lastRoomOpened
	while currentRoom != null:
		rooms.append(currentRoom)
		currentRoom = currentRoom.previousRoom
	return rooms
