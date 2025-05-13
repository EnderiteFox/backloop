class_name RoomGenerator
extends Resettable

const ROOM_PERSISTENCE: int = 4

var rooms: Array[Room]

var lastRoomOpened: Room = null

## Initializes the RoomGenerator. Called by the game.
func _init() -> void:
	super._init()
	Game.room_opened.connect(_on_room_opened)


func _delete_forward_rooms(room: Room) -> void:
	room.queue_free()
	for door in room.doors:
		if door.nextRoom != null:
			_delete_forward_rooms(door.nextRoom)


func _on_room_opened(room: Room) -> void:
	lastRoomOpened = room
	delete_far_rooms(room)


func reset() -> void:
	super.reset()
	rooms.clear()
	lastRoomOpened = null


## Instantiates a new random room and places it after a door. The room will not be fully generated yet and will be
## inactive until fully generated
func pregenerate_after_door(room: Room, door: Door) -> void:
	var roomPlacementHitboxLayer: int = room.roomPlacementHitbox.collision_layer
	room.roomPlacementHitbox.collision_layer = 0

	var possibleRooms: Array[String] = Game.roomList.get_random_rooms()

	for roomName in possibleRooms:
		var newRoom: Room = Game.roomList.get_room_scene(roomName).instantiate()

		# Deactivate the hitbox of the new room to prevent self collision
		var newRoomPlacementHitboxLayer: int = newRoom.roomPlacementHitbox.collision_layer
		newRoom.roomPlacementHitbox.collision_layer = 0

		# Position the new room
		room.add_sibling(newRoom)
		var nextDoor: Door = newRoom.place_after_door(door)

		# Create shapecast
		var shapeCast: ShapeCast3D = ShapeCast3D.new()
		newRoom.add_child(shapeCast)

		# Set shapecast parameters
		shapeCast.collide_with_bodies = false
		shapeCast.collide_with_areas = true

		shapeCast.target_position = Vector3.ZERO

		shapeCast.collision_mask = newRoomPlacementHitboxLayer

		# Test collision with each of the shapes of the room hitbox
		var collided: bool = false
		for node in newRoom.roomPlacementHitbox.get_children():
			if !(node is CollisionShape3D):
				continue

			var collisionShape3D := node as CollisionShape3D

			shapeCast.global_transform = collisionShape3D.global_transform
			shapeCast.shape = collisionShape3D.shape
			shapeCast.force_update_transform()
			shapeCast.force_shapecast_update()
			collided = collided || shapeCast.get_collision_count() > 0

		# Delete shapeCast
		shapeCast.free()

		if !collided:
			newRoom.previousRoom = room
			door.nextRoom = newRoom

			newRoom.doors.erase(nextDoor)
			nextDoor.queue_free()

			room.roomPlacementHitbox.collision_layer = roomPlacementHitboxLayer
			newRoom.roomPlacementHitbox.collision_layer = newRoomPlacementHitboxLayer

			return

		newRoom.free()

	# No room could be generated
	door.make_blocked()
	room.roomPlacementHitbox.collision_layer = roomPlacementHitboxLayer


## Finishes generation of a room, making it visible and activating it
func fully_generate(room: Room) -> void:
	if room == null:
		return
	room.visible = true
	for door in room.doors:
		pregenerate_after_door(room, door)
		door.opened.connect(func(): fully_generate(door.nextRoom))
	room.fullyGenerated = true


## Deletes rooms that are too far away from the opened room
func delete_far_rooms(room: Room) -> void:
	var currentRoom: Room = room
	var previousRoom: Room = null
	var currentDistance: int = ROOM_PERSISTENCE + 1

	while currentRoom != null:
		if currentRoom.previousRoom == null:
			break

		previousRoom = currentRoom
		currentRoom = currentRoom.previousRoom

		currentDistance -= 1

		if currentDistance < 0:
			currentRoom.queue_free()
			for door in currentRoom.doors:
				if door.nextRoom != null && door.nextRoom != previousRoom:
					_delete_forward_rooms(door.nextRoom)
		elif currentDistance == 0:
			for door in currentRoom.doors:
				door.silent_lock(false)
