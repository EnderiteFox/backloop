class_name GrinManager
extends MobManager

const SPAWN_CHANCE: float = 0.1
const SPAWN_CHANCE_FAIL_BONUS: float = 0.2

const ROOM_COOLDOWN: int = 5

const MAX_SWITCH_SPAWN_ATTEMPTS: int = 15
const SWITCH_SPAWN_HEIGHT: float = 0.85
const SWITCH_RAYCAST_MASK: int = 1 | 8
const SWITCH_RAYCAST_DISTANCE: int = 10


var switch_scene: PackedScene = preload("uid://b5q042ip36ka0")


func _init() -> void:
	super._init(
		EntityManager.EntityType.GRIN,
		EntityManager.EntityCategory.AMBIENT,
		RoomOpenedSpawner.new(
			EntityManager.EntityType.GRIN,
			EntityManager.EntityCategory.AMBIENT,
			true,
			SPAWN_CHANCE,
			SPAWN_CHANCE_FAIL_BONUS,
			ROOM_COOLDOWN
		)
	)
	_get_mob_spawner().spawn.connect(_on_spawn)
	
	
func _get_mob_spawner() -> RoomOpenedSpawner:
	return mob_spawner as RoomOpenedSpawner
	
	
func _on_spawn(room: Room) -> void:
	var switch: LightSwitch = _spawn_switch(room)
	if switch == null:
		_get_mob_spawner().spawn_failed()
		return
		
	_spawn_grin(switch)
	_get_mob_spawner().spawn_succeeded()
	
	
	
func _spawn_switch(room: Room) -> LightSwitch:
	var raycast := RayCast3D.new()
	raycast.collision_mask = SWITCH_RAYCAST_MASK
	room.add_child(raycast)
	
	var switch: LightSwitch = null
	
	for i in range(MAX_SWITCH_SPAWN_ATTEMPTS):
		var pos: Vector3 = NavigationServer3D.map_get_random_point(
			room.local_nav_region.get_navigation_map(),
			2,
			true
		)
		raycast.global_position = pos + Vector3(0, SWITCH_SPAWN_HEIGHT, 0)
		var rotation: float = randf_range(0, TAU)
		raycast.target_position = Vector3(sin(rotation), 0, cos(rotation)) * SWITCH_RAYCAST_DISTANCE
		raycast.force_raycast_update()
		
		if not raycast.is_colliding()\
		or raycast.get_collider() == null\
		or not raycast.get_collider().is_in_group(Game.WALLS_GROUP):
			continue
			
		switch = switch_scene.instantiate()
		room.add_child(switch)
		switch.global_position = raycast.get_collision_point()
		switch.look_at(switch.global_position + raycast.get_collision_normal())
		switch.rotation.x = 0
		break
		
	room.remove_child(raycast)
	raycast.free()
	
	return switch
	
	
func _spawn_grin(_switch: LightSwitch) -> void:
	pass
