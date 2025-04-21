class_name TheShadeManager
extends Resettable

const SPAWN_CHANCE: float = 0.3
const LENIENCE_TIME: float = 1.0
const ACTIVE_TIME: float = 2.0

const SPAWN_SAFE_DELAY: float = 1.5

const DESPAWN_BLACKOUT_TIME: float = 0.2

var isActive: bool = false

var spawn_points: Dictionary[Room, Array] = {}


func _init() -> void:
	Game.room_opened.connect(_on_room_opened)
	
	
func _on_room_opened(room: Room) -> void:
	Game.get_tree().create_timer(SPAWN_SAFE_DELAY).timeout.connect(_on_safe_delay_timeout.bind(room))
	room.tree_exiting.connect(_on_room_exit_tree.bind(room))
	
	
func _on_room_exit_tree(room: Room) -> void:
	if room.is_queued_for_deletion():
		spawn_points.erase(room)
	
	
func _on_safe_delay_timeout(room: Room) -> void:
	if randf() < SPAWN_CHANCE\
	and not isActive\
	and Game.player.is_alive\
	and spawn_points.has(room)\
	and not spawn_points[room].is_empty():
		spawn_the_shade_in_room(room)
	
	
func spawn_the_shade_in_room(room: Room) -> void:
	var selected_spawn: TheShadeSpawnPoint = spawn_points[room].pick_random()
	
	# Delete other spawn points
	for spawn_point in spawn_points[room]:
		if spawn_point != selected_spawn:
			spawn_point.queue_free()
		
	# Erase spawn points from map
	spawn_points.erase(room)
	
	if randf() < SPAWN_CHANCE:
		selected_spawn.spawn_the_shade()
	else:
		selected_spawn.queue_free()


func reset() -> void:
	isActive = false
	spawn_points = {}
