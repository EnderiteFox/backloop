class_name RoomList
extends RefCounted

var roomsConfig: Dictionary[String, float] = {
	"straightCorridor": 1.0,
	"tShapeTwoWindows": 1.0,
	"donut": 1.0
}
var rooms: Dictionary[PackedScene, float] = {}

func load_rooms() -> void:
	for roomName in roomsConfig:
		if roomsConfig[roomName] == 0:
			continue
		rooms[load("res://scene/rooms/" + roomName + ".tscn") as PackedScene] = roomsConfig[roomName]


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
			if curr + possibleRooms[room] >= chosen:
				roomList.append(room)
				possibleRooms.erase(room)
				continue
			curr += rooms[room]

	return roomList
