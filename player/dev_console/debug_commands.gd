class_name DebugCommands
extends Node

const ENTER_ROOM_MAX_TRIES: int = 10

@export var dev_console: DevConsole


func _ready() -> void:
	dev_console.ready.connect(
		func():
			dev_console.command_tree.register_callable(["spawn"], ["monster"], spawn)
			dev_console.command_tree.register_callable(["spawn"], ["the_shade", "where"], spawn_the_shade)
			dev_console.command_tree.register_callable(["give"], ["item"], give)
			dev_console.command_tree.register_callable(["force_next_room"], ["room_name"], force_next_room)
			dev_console.command_tree.register_callable(["enter_room"], ["room_name"], enter_room)
	)


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
	_enter_room(room, ENTER_ROOM_MAX_TRIES)

	
func _enter_room(room: String, remaining_tries: int) -> void:
	if Game.roomGenerator.rooms.is_empty():
		dev_console.print_error_console("No room to generate the new room after!")
		return
		
	# Get last room generated
	var prev_last_room: Room = Game.roomGenerator.rooms[-1]
	
	# If the room is not fully generated, generate it
	if not prev_last_room.fullyGenerated:
		Game.roomGenerator.fully_generate(prev_last_room)

	# Delete all rooms except one
	for deleted_room in Game.roomGenerator.rooms:
		if deleted_room != prev_last_room:
			deleted_room.queue_free()
		
	# Set next and previous rooms for the remaining room to null, close and unblock them
	prev_last_room.previousRoom = null
	for door in prev_last_room.doors:
		door.nextRoom = null
		door.state = Door.State.NORMAL
		
	# Update the room list accordingly
	Game.roomGenerator.rooms.clear()
	Game.roomGenerator.rooms.append(prev_last_room)
	
	# Choose a random door in the remaining room
	var prev_last_door: Door = prev_last_room.doors.pick_random()
	
	# Generate a random room after the chosen door
	Game.roomGenerator.pregenerate_after_door(prev_last_room, prev_last_door)
	
	# Get the newly generated room
	var last_room: Room = prev_last_door.nextRoom
	
	# If last_room is null, generation failed, retry
	if last_room == null:
		if remaining_tries > 0:
			dev_console.print_info_console("Failed to generate room to enter, retrying...")
			_enter_room(room, remaining_tries - 1)
			return
		else:
			dev_console.print_error_console("Failed to generate any room, can't recover")
			return
		
	# Close all doors of the previous room
	for door in prev_last_room.doors:
		door.instant_close()
		
	# Force the next generated room and fully generate the last room
	# If trying to fallback, don't force the room
	if remaining_tries >= 0:
		Game.roomList.forcedNextRoom = room
	Game.roomGenerator.fully_generate(last_room)
	
	# The first door of the last room has the wanted room
	var wanted_door: Door = last_room.doors.front()
	
	# If the wanted door is null, the wanted room failed to generate, retry
	if wanted_door == null:
		if remaining_tries > 0:
			dev_console.print_info_console("Failed to generate room to enter, retrying...")
			_enter_room(room, remaining_tries - 1)
			return
		elif wanted_door.nextRoom == null:
			dev_console.print_error_console("Failed to generate wanted room, generating another room")
			_enter_room(room, remaining_tries - 1)
			return
		else:
			dev_console.print_error_console("Failed to generate wanted room, entering another room")
		
	# Open the wanted door
	wanted_door.interaction_hitbox.interacted.emit()
	
	if remaining_tries >= 0:
		dev_console.print_info_console("Entered room %s" % room)
