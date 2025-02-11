extends Node3D
class_name Room

@warning_ignore("unused_signal")
signal room_opened

@export var doors: Array[Door]
@export var roomPlacementShapeCast: MultiShapeCast3D
@export var roomPlacementHitbox: Area3D
@export var anyMonsterNode: MonsterNode

var fullyGenerated: bool = false;

var previousRoom: Room = null

var roomsBeforeDespawn: int = Game.roomGenerator.ROOM_PERSISTENCE

func _ready() -> void:
	self.visible = false
	Game.roomGenerator.rooms.append(self)
	Game.room_opened.connect(_on_room_opened)


func _on_room_opened(_room: Room) -> void:
	if !fullyGenerated:
		return
	roomsBeforeDespawn -= 1
	if roomsBeforeDespawn == 0:
		for door in doors:
			door.close()
	elif roomsBeforeDespawn < 0:
		Game.roomGenerator.rooms.erase(self)
		for door in doors:
			if !door.nextRoom.fullyGenerated:
				Game.roomGenerator.rooms.erase(door.nextRoom)
				door.nextRoom.queue_free()
		self.queue_free()

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
