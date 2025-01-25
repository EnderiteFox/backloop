extends Resource
class_name RoomList

var rooms: Dictionary = {
	"straight_corridor": 1.0,
	"tShapeTwoWindows": 1.0
}

func load_rooms() -> void:
	var loadedRooms: Dictionary = {}
	for roomName in rooms:
		loadedRooms[load("res://scene/rooms/" + roomName + ".tscn")] = rooms[roomName]
	rooms = loadedRooms
	
func get_random_room() -> PackedScene:
	if rooms.size() == 0:
		push_error("No card is registered")
		return null
	var weight_sum: float = 0
	for room in rooms:
		weight_sum += rooms[room]
	var chosen: float = randf() * weight_sum
	var curr: float = 0
	for room in rooms:
		if curr + rooms[room] > chosen:
			return room
		curr += rooms[room]
	return rooms.keys[-1]
