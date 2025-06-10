@tool
class_name Room
extends Node3D

@warning_ignore("unused_signal")
signal room_opened

@export var doors: Array[Door]
@export var roomPlacementHitbox: Area3D
@export var anyMonsterNode: MonsterNode
@export var nav_region: NavigationRegion3D

var fullyGenerated: bool = false;

var previousRoom: Room = null

@export_tool_button("Prepare room") var editor_find_elements_action: Callable = _editor_prepare_room

func _ready() -> void:
	if !Engine.is_editor_hint():
		Game.roomGenerator.rooms.append(self)


func _editor_prepare_room() -> void:
	var monster_nodes: Array[MonsterNode] = _editor_get_monster_nodes(self)

	if monster_nodes.is_empty():
		push_warning("No monster nodes were found in the room!")
		return

	anyMonsterNode = monster_nodes[0]
	for monster_node in monster_nodes:
		monster_node._editor_update_path()
		
	for node in get_children():
		if node is NavigationRegion3D:
			self.nav_region = node
			self.nav_region.bake_navigation_mesh()
			break


func _editor_get_monster_nodes(node: Node) -> Array[MonsterNode]:
	var found_nodes: Array[MonsterNode] = []
	if node is MonsterNode:
		found_nodes.append(node)
	for child in node.get_children(true):
		found_nodes.append_array(_editor_get_monster_nodes(child))
	return found_nodes


func place_after_door(door: Door) -> Door:
	if door in doors:
		printerr("Can't place room after a door from the same room!")
		return
	
	var selfDoor: Door = doors.pick_random()
	
	var rotOffset: float = angle_difference(selfDoor.global_rotation.y, self.global_rotation.y) + PI
	self.global_rotation.y = door.global_rotation.y + rotOffset
	
	var posOffset: Vector3 = self.global_position - selfDoor.global_position
	self.global_position = door.global_position + posOffset

	return selfDoor
