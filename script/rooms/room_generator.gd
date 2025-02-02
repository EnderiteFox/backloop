extends RefCounted
class_name RoomGenerator

const ROOM_PERSISTENCE: int = 4

var rooms: Array[Room]

var lastRoomOpened: Room = null


## Initializes the RoomGenerator. Called by the game.
func ready() -> void:
	Game.room_opened.connect(func(room): lastRoomOpened = room)

func pregenerate_after_door(room: Room, door: Door) -> void:
	var newRoom: Room = Game.roomList.get_random_room().instantiate()
	room.add_sibling(newRoom)
	newRoom.previousRoom = room
	newRoom.place_after_door(door)
	door.nextRoom = newRoom
	
func fully_generate(room: Room) -> void:
	if room == null:
		return
	room.visible = true
	for door in room.doors:
		pregenerate_after_door(room, door)
		door.opened.connect(func(): fully_generate(door.nextRoom))
	room.fullyGenerated = true
