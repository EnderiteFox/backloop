## Handles the loading of room data
class_name RoomList
extends RefCounted

const ROOM_TEMPLATES_FOLDER: String = "res://room_templates/"

var room_infos: Dictionary[StringName, RoomInfo]
var loaded_rooms: Dictionary[StringName, PackedScene]

var forcedNextRoom: String


## Loads the list of rooms as RoomInfos
func load_room_infos() -> void:
	# Don't load room infos multiple times
	if not room_infos.is_empty():
		return

	_load_room_infos(ROOM_TEMPLATES_FOLDER)
	
	
## Recursively loads all room infos in the given directory
func _load_room_infos(directory: String) -> void:
	for resource in ResourceLoader.list_directory(directory):
		if resource.ends_with("/"):
			_load_room_infos(directory + resource)
		elif resource.get_extension() == "tres":
			var loaded: Resource = load(directory + resource)
			if not loaded is RoomInfo:
				continue
			room_infos[loaded.id] = loaded
			

## Get rooms in a random weighted order
## Performs a weighted selection of rooms until the pool is empty, and returns the rooms in the order
## they were selected
## This function does not load any room, and just returns a list of room names
func get_random_rooms() -> Array[StringName]:
	if forcedNextRoom:
		var result: Array[StringName] = [forcedNextRoom]
		forcedNextRoom = &""
		return result
	
	var room_pool: Dictionary[StringName, RoomInfo] = room_infos.duplicate()
	var weight_sum: float = room_infos.values().reduce(func(acc, x): return acc + x.spawn_weight, 0)

	var room_list: Array[StringName] = []

	while !room_pool.is_empty():
		if room_pool.size() == 1:
			room_list.append(room_pool.keys()[0])
			break

		var chosen: float = randf() * weight_sum
		var curr: float = 0
		for room in room_pool.keys():
			if curr + room_pool[room].spawn_weight >= chosen:
				room_list.append(room)
				room_pool.erase(room)
				continue
			curr += room_infos[room].spawn_weight

	return room_list
	
	
## Returns an instance of the given room name
## If the room was not loaded, loads the room
func get_room_scene(room_id: StringName) -> PackedScene:
	if not loaded_rooms.has(room_id):
		if not room_infos.has(room_id):
			Game.print_error("No room info for room ", room_id)
			return
		
		var room_scene: PackedScene = load(room_infos[room_id].scene)
		loaded_rooms[room_id] = room_scene
		return room_scene
	
	return loaded_rooms[room_id]
