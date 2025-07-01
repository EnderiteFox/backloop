class_name DebugCommands
extends Node

@export var dev_console: DevConsole


func spawn(monster: String) -> void:
	match monster:
		"outrun":
			Game.outrun.spawn()
		_:
			dev_console.print_error_console("Unknown monster: %s" % monster)
			
		
func _spawn_the_shade(room: Room) -> void:
	if not Game.the_shade.spawn(room):
		dev_console.print_error_console("Failed to spawn The Shade")
		
			
func spawn_the_shade(_the_shade: String, where: String) -> void:
	if Game.roomGenerator.rooms.is_empty():
		dev_console.print_error_console("No room to spawn The Shade in")
		return
		
	match where:
		"random":
			_spawn_the_shade(Game.roomGenerator.rooms.pick_random())
		"last":
			_spawn_the_shade(Game.roomGenerator.lastRoomOpened)
		_:
			dev_console.print_error_console("Invalid location: %s" % where)
	
	
func give(item: String) -> void:
	match item:
		"battery":
			Game.player.inventory.add_consumable(Consumable.Type.BATTERY)
			dev_console.print_console("Gave one battery")
		_:
			dev_console.print_error_console("Unknown item: %s" % item)
	
	
func force_next_room(room: String) -> void:
	Game.roomList.forcedNextRoom = room
	dev_console.print_info_console("Set next forced room to %s" % room)
	
	
func enter_room(room: String) -> void:
	if Game.roomGenerator.rooms.is_empty():
		dev_console.print_error_console("No room to generate the new room after!")
		return

	Game.roomList.forcedNextRoom = room
	var last_room: Room = Game.roomGenerator.rooms[-1]
	var last_door: Door = last_room.doors.pick_random()

	if not last_room.fullyGenerated:
		Game.roomGenerator.fully_generate(last_room)
	
	# Delete all rooms except the last one
	var to_remove: Array[Room]
	for deleted_room in Game.roomGenerator.rooms:
		if deleted_room == last_room or (last_room.previousRoom != null and last_room.previousRoom == deleted_room):
			continue
			
		deleted_room.roomPlacementHitbox.collision_mask = 0
		deleted_room.get_parent().remove_child(deleted_room)
		deleted_room.queue_free()
		to_remove.append(deleted_room)

	# Remove deleted rooms from room list
	for deleted_room in to_remove:
		Game.roomGenerator.rooms.erase(deleted_room)
	# TODO: Automatically remove rooms from the room list when exiting tree
	
	# Close doors that lead to the void
	if last_room.previousRoom != null:
		for door in last_room.previousRoom.doors:
			door.instant_close()
	
	Game.roomGenerator.pregenerate_after_door(last_room, last_door)
	
	last_door.interaction_hitbox.interacted.emit()
	dev_console.print_info_console("Entered room %s" % room)
		
