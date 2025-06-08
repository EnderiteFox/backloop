class_name TheShadeManager
extends Resettable

const CHECKED_SPAWN_RAYCAST_POSITIONS: Array[Vector3] = [
	Vector3.ZERO,
	Vector3.UP * 0.5,
	Vector3.UP,
	Vector3.UP * 1.5,
]
const MAX_SPAWN_VISIBLE_CHECK_TRIES: int = 10
const RAYCAST_COLLISION_MASK: int = 1 | 2 | 8

var is_active: bool = false
var the_shade_scene: PackedScene = preload("uid://b7y1pcrm32hly")


## Spawn The Shade in a room. Returns [code]true[/code] if spawned successfully, or [code]false[/code] if The Shade 
## couldn't spawn in this room
func spawn(room: Room) -> bool:
	for i in range(MAX_SPAWN_VISIBLE_CHECK_TRIES):
		var position: Vector3 = NavigationServer3D.map_get_random_point(
			room.nav_region.get_navigation_map(),
			1,
			true
		)
		
		if _any_pos_sees_player(
			room, 
			CHECKED_SPAWN_RAYCAST_POSITIONS.map(
				func(vec: Vector3): return vec + position
			)
		):
			continue
			
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
		
		var the_shade: TheShade = the_shade_scene.instantiate()
		room.add_sibling(the_shade)
		the_shade.global_position = position
		Game.player.dev_console.print_info_console("The Shade spawned")
		return true
		
	Game.player.dev_console.print_info_console("The Shade failed to spawn, max amount of attempts reached")
	return false
	

## Returns true if any of the given global positions have line of sight with the player
func _any_pos_sees_player(room: Room, positions: Array) -> bool:
	var collided: bool = false
	
	# Create raycast
	var raycast := RayCast3D.new()
	room.add_child(raycast)
	raycast.collision_mask = RAYCAST_COLLISION_MASK
	raycast.collide_with_areas = true
	
	# Check positions
	for position in positions:
		raycast.global_position = position
		raycast.target_position = raycast.to_local(Game.player.camera.global_position)
		raycast.force_raycast_update()
		if raycast.get_collider() is Player:
			collided = true
			break
		
	# Clear raycast
	room.remove_child(raycast)
	raycast.queue_free()
	
	return collided
	
