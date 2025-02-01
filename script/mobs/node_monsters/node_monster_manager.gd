extends RefCounted
class_name NodeMonsterManager

const START_POINT_DISTANCE: float = 10
const END_POINT_DISTANCE: float = 10


## Returns the rooms that are on the path, from the farthest room to the last room opened
func _get_path_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	var currentRoom: Room = Game.roomGenerator.lastRoomOpened
	while currentRoom != null:
		rooms.append(currentRoom)
		currentRoom = currentRoom.previousRoom
	rooms.reverse()
	return rooms



## Returns the path that the node monster should take.[br]
## The path is made of the room paths back-to-back, with a start node and an end node added,
## whose location is extended from the two first/last nodes.[br]
## Returns an empty array if pathfinding failed.[br]
func get_node_monster_path() -> PackedVector3Array:
	var path: PackedVector3Array = []

	var pathRooms: Array[Room] = _get_path_rooms()

	for room in pathRooms:
		var roomPath: PackedVector3Array = _pathfind_room_graph(room)
		if roomPath.is_empty():
			return []
		path.append_array(roomPath)

	if path.size() < 2:
		return []

	path.insert(0, path[0] + path[1].direction_to(path[0]) * START_POINT_DISTANCE)
	path.push_back(path[-1] + path[-2].direction_to(path[-1]) * END_POINT_DISTANCE)

	return path




## Returns the path from the start to the end of the room. Returns an empty array if pathfinding failed
func _pathfind_room_graph(room: Room) -> PackedVector3Array:
	var graph: Array[MonsterNode] = room.anyMonsterNode.graph

	# Find start node
	var startNode: MonsterNode = null
	for node in graph:
		if node.nodeState == MonsterNode.NodeState.ROOM_START:
			startNode = node
			break
	if startNode == null:
		return []

	# Find end node
	var endNode: MonsterNode = null
	for node in graph:
		if node.nodeState == MonsterNode.NodeState.ROOM_END:
			endNode = node
			break

	# If end node not found (eg. last room), find one, by taking a random unopened exit door
	# and taking the closest node
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

	# Assign id to each node in the graph
	var nodeIds: Dictionary = {}
	var currentId: int = 0
	for node in graph:
		nodeIds[node] = currentId
		currentId += 1

	# Init pathfinding graph
	var astar := AStar3D.new()

	for node in nodeIds.keys():
		astar.add_point(nodeIds[node], node.global_position)

	for node in graph:
		for otherNode in node.nextNodes:
			astar.connect_points(nodeIds[node], nodeIds[otherNode], false)

	return astar.get_point_path(nodeIds[startNode], nodeIds[endNode])

