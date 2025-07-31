class_name RoomList
extends RefCounted

var roomsConfig: Dictionary[String, float] = {
	"straightCorridor": 1.0,
	"tShapeTwoWindows": 1.0,
	"donut": 1.0
}
var roomScenes: Dictionary[String, PackedScene] = {}

var forcedNextRoom: String = ""

## Get rooms in a random weighted order
## Performs a weighted selection of rooms until the pool is empty, and returns the rooms in the order
## they were selected
## This function does not load any room, and merely returns a list of room names
func get_random_rooms() -> Array[String]:
	if forcedNextRoom:
		var result: Array[String] = [forcedNextRoom]
		forcedNextRoom = ""
		return result
	
	var possibleRooms: Dictionary = roomsConfig.duplicate()
	var weight_sum: float         = possibleRooms.values().reduce(func(acc, x): return acc + x, 0)

	var roomList: Array[String] = []

	while !possibleRooms.is_empty():
		if possibleRooms.size() == 1:
			roomList.append(possibleRooms.keys()[0])
			break

		var chosen: float = randf() * weight_sum
		var curr: float = 0
		for room in possibleRooms:
			if curr + possibleRooms[room] >= chosen:
				roomList.append(room)
				possibleRooms.erase(room)
				continue
			curr += roomsConfig[room]

	return roomList
	
	
## Returns an instance of the given room name
## If the room was not loaded, loads the room
func get_room_scene(roomName: String) -> PackedScene:
	if not roomScenes.has(roomName):
		roomScenes[roomName] = load("res://rooms/" + roomName + ".tscn") as PackedScene
		
	return roomScenes[roomName]
