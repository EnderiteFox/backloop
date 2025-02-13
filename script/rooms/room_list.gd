extends RefCounted
class_name RoomList

var rooms: Dictionary = {
	"straightCorridor": 0.0,
	"tShapeTwoWindows": 1.0,
	"donut": 0.0
}

func load_rooms() -> void:
	var loadedRooms: Dictionary = {}
	for roomName in rooms:
		if rooms[roomName] == 0:
			continue
		loadedRooms[load("res://scene/rooms/" + roomName + ".tscn")] = rooms[roomName]
	rooms = loadedRooms

func get_random_rooms() -> Array[PackedScene]:
	var possibleRooms: Dictionary = rooms.duplicate()
	var weight_sum: float         = possibleRooms.values().reduce(func(acc, x): return acc + x, 0)

	var roomList: Array[PackedScene] = []

	while !possibleRooms.is_empty():
		if possibleRooms.size() == 1:
			roomList.append(possibleRooms.keys()[0])
			break

		var chosen: float = randf() * weight_sum
		var curr: float = 0
		for room in possibleRooms:
			if curr + possibleRooms[room] > chosen:
				roomList.append(room)
				possibleRooms.erase(room)
				continue
			curr += rooms[room]

	return roomList
