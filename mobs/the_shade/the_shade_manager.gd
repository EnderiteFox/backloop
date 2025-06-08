class_name TheShadeManager
extends Resettable

var is_active: bool = false
var the_shade_scene: PackedScene = preload("uid://b7y1pcrm32hly")


## Spawn The Shade in a room. Returns [code]true[/code] if spawned successfully, or [code]false[/code] if The Shade 
## couldn't spawn in this room
func spawn(room: Room) -> bool:
	var the_shade: TheShade = the_shade_scene.instantiate()
	room.add_child(the_shade)
	var position: Vector3 = NavigationServer3D.map_get_random_point(
		room.nav_region.get_navigation_map(),
		1,
		true
	)
	the_shade.global_position = position
	Game.player.dev_console.print_info_console("The Shade spawned")
	return true
