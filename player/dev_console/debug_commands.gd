class_name DebugCommands
extends Node

const ENTER_ROOM_MAX_TRIES: int = 10
const GAME_OVER_SCENE: PackedScene = preload("uid://c1hbjeqkobclu")

@export var dev_console: DevConsole


func _ready() -> void:
	dev_console.ready.connect(
		func():
			dev_console.command_tree.register_callable(["spawn"], ["entity"], spawn)
			dev_console.command_tree.register_callable(["give"], ["item"], give_item)
			dev_console.command_tree.register_callable(["give"], ["consumable", "amount"], give_consumable)
			dev_console.command_tree.register_callable(["give"], ["consumable"], give_consumable.bind(1))
			dev_console.command_tree.register_callable(["force_next_room"], ["room_name"], force_next_room)
			dev_console.command_tree.register_callable(["enter_room"], ["room_name"], enter_room)
			dev_console.command_tree.register_callable(["get_spawn_chance"], ["entity"], get_spawn_chance)
			dev_console.command_tree.register_callable(["set_spawn_chance"], ["entity", "chance"], set_spawn_chance)
			dev_console.command_tree.register_callable(["die"], [], die)
			dev_console.command_tree.register_callable(["time", "add"], ["amount"], time_add)
			dev_console.command_tree.register_callable(["time", "set"], ["amount"], time_set)
	)
	
	
func die() -> void:
	get_tree().change_scene_to_packed(GAME_OVER_SCENE)
	
	
func time_add(amount: int) -> void:
	Game.time += amount
	
	
func time_set(amount: int) -> void:
	Game.time = amount


func spawn(entity_id: String) -> void:
	var entity: EntityManager.EntityType = Game.entity_manager.get_entity_from_id(entity_id)
	if entity == null:
		Game.print_error("Unknown entity: ", entity_id)
		return
		
	var mob_manager: MobManager = Game.entity_manager.get_manager(entity)
	if mob_manager == null:
		Game.print_error(entity_id, " has no registered manager")
		return
		
	var mob_spawner: MobSpawner = mob_manager.mob_spawner
	if not mob_spawner.supports_force_spawn:
		Game.print_error(entity_id, " does not support force spawning")
		return
		
	var success: bool = mob_spawner.force_spawn()
	if success:
		# Let the MobManager print in the console on success
		return
	else:
		Game.print_error("Failed to spawn ", entity_id)
		
		
func give_item(item: String) -> void:
	if not Game.item_manager.item_infos.has(item):
		Game.print_error("Unknown item: ", item)
		return
	
	Game.player.inventory.add_item(Game.item_manager.item_infos[item])
	
	
func give_consumable(item: String, amount: int) -> void:
	if not Game.item_manager.consumable_infos.has(item):
		Game.print_error("Unknown consumable: ", item)
		return
	
	Game.player.inventory.add_consumable(Game.item_manager.consumable_infos[item].type, amount)
	
	
func force_next_room(room: String) -> void:
	Game.room_list.forcedNextRoom = room
	Game.print_info("Set next forced room to ", room)
	
	
func enter_room(room: String) -> void:
	_enter_room(room, ENTER_ROOM_MAX_TRIES)

	
func _enter_room(room: String, remaining_tries: int) -> void:
	if Game.room_generator.rooms.is_empty():
		Game.print_error("No room to generate the new room after!")
		return
		
	# Get last room generated
	var prev_last_room: Room = Game.room_generator.rooms[-1]
	
	# If the room is not fully generated, generate it
	if not prev_last_room.fullyGenerated:
		Game.room_generator.fully_generate(prev_last_room)

	# Delete all rooms except one
	for deleted_room in Game.room_generator.rooms:
		if deleted_room != prev_last_room:
			deleted_room.queue_free()
		
	# Set next and previous rooms for the remaining room to null, close and unblock them
	prev_last_room.previousRoom = null
	for door in prev_last_room.doors:
		door.nextRoom = null
		door.state = Door.State.NORMAL
		
	# Update the room list accordingly
	Game.room_generator.rooms.clear()
	Game.room_generator.rooms.append(prev_last_room)
	
	# Choose a random door in the remaining room
	var prev_last_door: Door = prev_last_room.doors.pick_random()
	
	# Generate a random room after the chosen door
	Game.room_generator.pregenerate_after_door(prev_last_room, prev_last_door)
	
	# Get the newly generated room
	var last_room: Room = prev_last_door.nextRoom
	
	# If last_room is null, generation failed, retry
	if last_room == null:
		if remaining_tries > 0:
			Game.print_info("Failed to generate room to enter, retrying...")
			_enter_room(room, remaining_tries - 1)
			return
		else:
			Game.print_error("Failed to generate any room, can't recover")
			return
		
	# Close all doors of the previous room
	for door in prev_last_room.doors:
		door.instant_close()
		
	# Force the next generated room and fully generate the last room
	# If trying to fallback, don't force the room
	if remaining_tries >= 0:
		Game.room_list.forcedNextRoom = room
	Game.room_generator.fully_generate(last_room)
	
	# The first door of the last room has the wanted room
	var wanted_door: Door = last_room.doors.front()
	
	# If the wanted door is null, the wanted room failed to generate, retry
	if wanted_door == null:
		if remaining_tries > 0:
			Game.print_info("Failed to generate room to enter, retrying...")
			_enter_room(room, remaining_tries - 1)
			return
		elif wanted_door.nextRoom == null:
			Game.print_error("Failed to generate wanted room, generating another room")
			_enter_room(room, remaining_tries - 1)
			return
		else:
			Game.print_error("Failed to generate wanted room, entering another room")
		
	# Open the wanted door
	wanted_door.interaction_hitbox.interacted.emit()
	
	if remaining_tries >= 0:
		Game.print_info("Entered room ", room)
		
		
func get_spawn_chance(entity_id: String) -> void:
	var entity: EntityManager.EntityType = Game.entity_manager.get_entity_from_id(entity_id)
	if entity == null:
		Game.print_error("Unknown entity: ", entity_id)
		return
		
	var mob_spawner: MobSpawner = Game.entity_manager.get_manager(entity).mob_spawner
	if not mob_spawner is RoomOpenedSpawner:
		Game.print_error(entity_id, " does not spawn on door opening")
		return
		
	var room_opened_spawner: RoomOpenedSpawner = mob_spawner as RoomOpenedSpawner
		
	Game.print_info("Current spawn chance for ", entity_id, ": %.3f" % room_opened_spawner.current_spawn_chance)
	
	
func set_spawn_chance(entity_id: String, chance: float) -> void:
	var entity: EntityManager.EntityType = Game.entity_manager.get_entity_from_id(entity_id)
	if entity == null:
		Game.print_error("Unknown entity: ", entity_id)
		return
		
	var mob_spawner: MobSpawner = Game.entity_manager.get_manager(entity).mob_spawner
	if not mob_spawner is RoomOpenedSpawner:
		Game.print_error(entity_id, " does not spawn on door opening")
		return
		
	var room_opened_spawner: RoomOpenedSpawner = mob_spawner as RoomOpenedSpawner
	
	room_opened_spawner.current_spawn_chance = clamp(chance, 0.0, 1.0)
	Game.print_info("Set the current spawn chance for ", entity_id, " to %.3f" % clamp(chance, 0.0, 1.0))
