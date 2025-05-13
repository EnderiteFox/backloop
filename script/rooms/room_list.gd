class_name RoomList
extends RefCounted

var roomsConfig: Dictionary[String, float] = {
	"straightCorridor": 1.0,
	"tShapeTwoWindows": 1.0,
	"donut": 1.0
}
var roomScenes: Dictionary[String, PackedScene] = {}


func get_random_rooms() -> Array[String]:
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
	
	
func get_room_scene(roomName: String) -> PackedScene:
	if not roomScenes.has(roomName):
		roomScenes[roomName] = load("res://rooms/" + roomName + ".tscn") as PackedScene
		
	return roomScenes[roomName]
