extends RefCounted
class_name RoomGenerator

const ROOM_PERSISTENCE: int = 4

var rooms: Array[Room]

var lastRoomOpened: Room = null


## Initializes the RoomGenerator. Called by the game.
func ready() -> void:
	Game.room_opened.connect(func(room): lastRoomOpened = room)

## Instantiates a new random room and places it after a door. The room will not be fully generated yet and will be
## inactive until fully generated
func pregenerate_after_door(room: Room, door: Door) -> void:
	room.roomPlacementHitbox.monitorable = false

	var possibleRooms: Array[PackedScene] = Game.roomList.get_random_rooms()

	for roomScene in possibleRooms:
		var newRoom: Room = roomScene.instantiate()
		newRoom.roomPlacementHitbox.monitorable = false
		room.add_sibling(newRoom)
		var nextDoor: Door = newRoom.place_after_door(door)

		if !newRoom.roomPlacementShapeCast.is_any_shape_colliding():
			newRoom.previousRoom = room
			door.nextRoom = newRoom

			newRoom.doors.erase(nextDoor)
			nextDoor.queue_free()

			room.roomPlacementHitbox.monitorable = true
			newRoom.roomPlacementHitbox.monitorable = true
			return

		newRoom.free()

	# No room could be generated
	door.silent_lock()
	room.roomPlacementHitbox.monitorable = true


## Finishes generation of a room, making it visible and activating it
func fully_generate(room: Room) -> void:
	if room == null:
		return
	room.visible = true
	for door in room.doors:
		pregenerate_after_door(room, door)
		door.opened.connect(func(): fully_generate(door.nextRoom))
	room.fullyGenerated = true
