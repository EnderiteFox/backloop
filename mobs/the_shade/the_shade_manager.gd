class_name TheShadeManager
extends Resettable

const SPAWN_CHANCE: float = 0.1
const SPAWN_FAIL_CHANCE_BONUS: float = 0.2
const SPAWN_TIMEOUT: float = 1.5

const MAX_SPAWN_VISIBLE_CHECK_TRIES: int = 15
const RAYCAST_COLLISION_MASK: int = 1 | 2 | 8

var is_active: bool = false
var the_shade_scene: PackedScene = preload("uid://b7y1pcrm32hly")
var spawn_raycasts_scene: PackedScene = preload("uid://ciwbfrfyc0x4x")

var spawn_fails: int = 0

# TODO: Handle the case where The Shade is in a room that is deleted


func _init() -> void:
	Game.room_opened.connect(_on_room_opened)


func _on_room_opened(room: Room) -> void:
	if is_active or randf() < SPAWN_CHANCE + SPAWN_FAIL_CHANCE_BONUS * spawn_fails:
		return
		
	room.get_tree().create_timer(SPAWN_TIMEOUT).timeout.connect(_on_spawn_timeout.bind(room))
		
		
func _on_spawn_timeout(room: Room) -> void:
	if spawn(room):
		spawn_fails = 0
		is_active = true
	else:
		spawn_fails += 1
	

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
	

## Spawn The Shade in a room. Returns [code]true[/code] if spawned successfully, or [code]false[/code] if The Shade 
## couldn't spawn in this room
func spawn(room: Room) -> bool:
	for i in range(MAX_SPAWN_VISIBLE_CHECK_TRIES):
		var position: Vector3 = NavigationServer3D.map_get_random_point(
			room.nav_region.get_navigation_map(),
			1,
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
			Game.player.dev_console.print_info_console("Potential issue: Failed to get ground position from NavMesh position")
			continue
		position = raycast.get_collision_point()
		
		if _pos_sees_player(room, position):
			continue
		
		var the_shade: TheShade = the_shade_scene.instantiate()
		room.add_sibling(the_shade)
		the_shade.global_position = position
		the_shade.navagent.set_navigation_map(room.nav_region.get_navigation_map())
		Game.player.dev_console.print_info_console("The Shade spawned")
		return true
		
	Game.player.dev_console.print_info_console("The Shade failed to spawn, max amount of attempts reached")
	return false
