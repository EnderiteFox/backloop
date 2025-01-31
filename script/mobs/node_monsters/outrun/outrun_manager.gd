extends RefCounted
class_name OutrunManager

var isActive: bool = false

func _init() -> void:
	pass
	# Game.room_opened.connect(_on_room_opened)

func _on_room_opened(_room: Room) -> void:
	pass

func _get_path_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	var currentRoom: Room = Game.roomGenerator.lastRoomOpened
	while currentRoom != null:
		rooms.append(currentRoom)
		currentRoom = currentRoom.previousRoom
	rooms.reverse()
	return rooms

func get_monster_node_path() -> Array[Vector3]:
	return []

func _pathfind_room_graph(room: Room) -> Array[MonsterNode]:
	var graph: Array[MonsterNode] = room.anyMonsterNode.graph

	var startNode: MonsterNode = null
	for node in graph:
		if node.nodeState == MonsterNode.NodeState.ROOM_START:
			startNode = node
			break
	if startNode == null:
		return []

	var endNode: MonsterNode = null
	for node in graph:
		if node.nodeState == MonsterNode.NodeState.ROOM_END:
			endNode = node
			break

	if endNode == null:
		var validExitDoors: Array[Door] = room.doors.filter(
			func(door):
				return !door.open
		)
		if validExitDoors.is_empty():
			return []
		validExitDoors.shuffle()

		var selectedExitDoor: Door = validExitDoors[0]
		var sortedNodes: Array[MonsterNode] = Array(graph)
		sortedNodes.sort_custom(
			func(node1, node2):
				return node1.global_position.distance_squared_to(selectedExitDoor.global_position) \
					< node2.global_position.distance_squared_to(selectedExitDoor.global_position)
		)

		if sortedNodes.is_empty():
			return []

		endNode = sortedNodes[0]
		endNode.nodeState = MonsterNode.NodeState.ROOM_END

	return []
