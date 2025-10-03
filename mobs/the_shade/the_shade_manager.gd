class_name TheShadeManager
extends MobManager

const SPAWN_CHANCE: float = 0.1
const SPAWN_FAIL_CHANCE_BONUS: float = 0.2
const SPAWN_TIMEOUT: float = 1.5

const ROOM_COOLDOWN: int = 5

const MAX_SPAWN_VISIBLE_CHECK_TRIES: int = 15
const RAYCAST_COLLISION_MASK: int = 1 | 2 | 8

var the_shade_scene: PackedScene = preload("uid://b7y1pcrm32hly")
var spawn_raycasts_scene: PackedScene = preload("uid://ciwbfrfyc0x4x")

# TODO: Handle the case where The Shade is in a room that is deleted


func _init() -> void:
	super._init(
		EntityManager.EntityType.THE_SHADE,
		EntityManager.EntityCategory.AMBIENT,
		RoomOpenedSpawner.new(
			EntityManager.EntityType.THE_SHADE,
			EntityManager.EntityCategory.AMBIENT,
			true,
			SPAWN_CHANCE,
			SPAWN_FAIL_CHANCE_BONUS,
			ROOM_COOLDOWN
		)
	)
	_get_mob_spawner().spawn.connect(_on_spawn)
	
	
func _get_mob_spawner() -> RoomOpenedSpawner:
	return mob_spawner as RoomOpenedSpawner
	
	
func _on_spawn(room: Room) -> void:
	room.get_tree().create_timer(SPAWN_TIMEOUT).timeout.connect(_on_spawn_timeout.bind(room))
		
		
func _on_spawn_timeout(room: Room) -> void:
	if spawn(room):
		_get_mob_spawner().spawn_succeeded()
		register_active()
	else:
		_get_mob_spawner().spawn_failed()
	

## Returns true if any of the global position have line of sight with the player
func _pos_sees_player(room: Room, position: Vector3) -> bool:
	# Instantiate raycast scene
	var spawn_raycasts: Node3D = spawn_raycasts_scene.instantiate()
	room.add_child(spawn_raycasts)
	spawn_raycasts.global_position = position
	spawn_raycasts.look_at(Game.player.camera.global_position)
	spawn_raycasts.rotation.x = 0

	# Check raycasts
	var any_collided: bool = false
	for child in spawn_raycasts.get_children():
		if child is RayCast3D:
			child.target_position = child.to_local(Game.player.camera.global_position)
			child.force_raycast_update()
			if child.is_colliding() and child.get_collider() is Player:
				any_collided = true
				break
		elif child is ShapeCast3D:
			child.target_position = Vector3.ZERO
			child.force_shapecast_update()
			if child.is_colliding():
				any_collided = true
				break
		else:
			push_warning("Unexpected type for The Shade spawn raycast node: %s" % child.get_class())

	# Remove raycasts
	spawn_raycasts.free()

	return any_collided
	

## Spawn The Shade in a room
## Returns [code]true[/code] if spawned successfully, or [code]false[/code] if The Shade couldn't spawn in this room
func spawn(room: Room) -> bool:
	var remaining_attempts: int = MAX_SPAWN_VISIBLE_CHECK_TRIES
	while remaining_attempts > 0:
		var position: Vector3 = NavigationServer3D.map_get_random_point(
			room.local_nav_region.get_navigation_map(),
			2,
			true
		)
		
		# Get position on ground
		var raycast := RayCast3D.new()
		room.add_child(raycast)
		raycast.global_position = position
		raycast.collision_mask = RAYCAST_COLLISION_MASK
		raycast.collide_with_areas = true
		raycast.target_position = Vector3.DOWN
		raycast.force_raycast_update()
		if not raycast.is_colliding():
			Game.print_info("Potential issue: Failed to get ground position from NavMesh position")
			remaining_attempts -= 1
			continue
		position = raycast.get_collision_point()
		
		if _pos_sees_player(room, position):
			remaining_attempts -= 1
			continue
		
		var the_shade: TheShade = the_shade_scene.instantiate()
		room.add_sibling(the_shade)
		the_shade.global_position = position
		Game.print_info("The Shade spawned")
		break
		
	if remaining_attempts <= 0:
		Game.print_info("The Shade failed to spawn, max amount of attempts reached")
		return false

	return true
