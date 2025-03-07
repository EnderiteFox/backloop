class_name Room
extends Node3D

@warning_ignore("unused_signal")
signal room_opened

@export var doors: Array[Door]
@export var roomPlacementHitbox: Area3D
@export var anyMonsterNode: MonsterNode

var fullyGenerated: bool = false;

var previousRoom: Room = null

func _ready() -> void:
	self.visible = false
	Game.roomGenerator.rooms.append(self)


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
