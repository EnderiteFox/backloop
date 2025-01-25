extends Node3D
class_name Room

@export var doors: Array[Door]
@export var roomPlacementHitbox: Area3D

func _ready() -> void:
	for door in doors:
		door.opened.connect(
			func():
				var room: Room = Game.roomList.get_random_room().instantiate()
				self.add_sibling(room)
				room.place_after_door(door)
		)

func place_after_door(door: Door) -> void:
	if door in doors:
		printerr("Can't place room after a door from the same room!")
		return
	
	var selfDoor: Door = doors.pick_random()
	
	var rotOffset: float = angle_difference(selfDoor.global_rotation.y, self.global_rotation.y) + PI
	self.global_rotation.y = door.global_rotation.y + rotOffset
	
	var posOffset: Vector3 = self.global_position - selfDoor.global_position
	self.global_position = door.global_position + posOffset
	
	selfDoor.queue_free()
