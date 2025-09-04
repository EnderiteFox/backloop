@tool
class_name Room
extends Node3D

@warning_ignore("unused_signal")
signal room_opened

## Emitted once the animation for the door opening finishes
@warning_ignore("unused_signal")
signal fully_opened

@export var doors: Array[Door]
@export var roomPlacementHitbox: Area3D
@export var anyMonsterNode: MonsterNode
@export var local_nav_region: NavigationRegion3D
@export var global_nav_region: NavigationRegion3D

var fullyGenerated: bool = false;

var previousRoom: Room = null

@export_tool_button("Prepare room") var editor_find_elements_action: Callable = _editor_prepare_room

func _ready() -> void:
	if !Engine.is_editor_hint():
		self.tree_exiting.connect(_on_exit_tree)
		
		Game.roomGenerator.rooms.append(self)
		
		# Put the room's navigation mesh on its own map
		var map: RID = NavigationServer3D.map_create()
		NavigationServer3D.map_set_up(map, Vector3.UP)
		NavigationServer3D.map_set_active(map, true)
		local_nav_region.set_navigation_map(map)
		
		
func _on_exit_tree() -> void:
	Game.roomGenerator.rooms.erase(self)
	
	if self.previousRoom != null:
		for door in self.previousRoom.doors:
			if door.nextRoom == self:
				door.nextRoom = null
				
	for door in doors:
		if door.nextRoom != null:
			door.nextRoom.previousRoom = null


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
			self.global_nav_region = node
			if self.global_nav_region.navigation_mesh == null:
				self.global_nav_region.navigation_mesh = NavigationMesh.new()
			self.global_nav_region.bake_navigation_mesh()
			assert(node.get_child_count() == 1)
			assert(node.get_children()[0] is NavigationRegion3D)
			self.local_nav_region = node.get_children()[0]
			if self.local_nav_region.navigation_mesh == null:
				self.local_nav_region.navigation_mesh = NavigationMesh.new()
			self.local_nav_region.bake_navigation_mesh()
			break
	assert(false, "Failed to get global nav region")


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
