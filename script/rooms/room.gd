@tool
class_name Room
extends Node3D

@warning_ignore("unused_signal")
signal room_opened

## Emitted once the animation for the door opening finishes
@warning_ignore("unused_signal")
signal fully_opened

@export var doors: Array[Door]
@export var monster_nodes: Array[MonsterNode]

@onready var roomPlacementHitbox: Area3D = %PlacementHitbox
@onready var local_nav_region: NavigationRegion3D = %LocalNavigationRegion
@onready var global_nav_region: NavigationRegion3D = %GlobalNavigationRegion

#region Editor organization nodes

@onready var doors_holder: Node = %Doors
@onready var monster_nodes_holder: Node = %MonsterNodes
@onready var voxel_gi: VoxelGI = %VoxelGI

#endregion

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
	monster_nodes = []
	if monster_nodes_holder == null:
		push_error("Monster node holder not found!")
	else:
		for node in monster_nodes_holder.get_children():
			if node is MonsterNode:
				monster_nodes.append(node)
				node._editor_update_path()
	
	doors = []
	if doors_holder == null:
		push_error("Door holder not found!")
	else:
		for node in doors_holder.get_children():
			if node is Door:
				doors.append(node)
	
	if voxel_gi == null:
		push_error("VoxelGI not found!")
	else:
		voxel_gi.bake()
	
	if global_nav_region.navigation_mesh == null:
		global_nav_region.navigation_mesh = NavigationMesh.new()
	global_nav_region.bake_navigation_mesh()
	
	if local_nav_region.navigation_mesh == null:
		local_nav_region.navigation_mesh = NavigationMesh.new()
	local_nav_region.bake_navigation_mesh()


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
