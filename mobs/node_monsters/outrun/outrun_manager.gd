class_name OutrunManager
extends MobManager

const SPAWN_CHANCE: float = 0.01
const ROOM_COOLDOWN: int = 5

var outrunScene: PackedScene = preload("uid://f57tvg8catxs")


func _init() -> void:
	super._init(
		EntityManager.EntityType.OUTRUN,
		EntityManager.EntityCategory.RUSHER,
		RoomOpenedSpawner.new(
			EntityManager.EntityType.OUTRUN,
			EntityManager.EntityCategory.RUSHER,
			true,
			SPAWN_CHANCE,
			0.0,
			ROOM_COOLDOWN
		)
	)
	_get_mob_spawner().spawn.connect(spawn.unbind(1))
	
	
func _get_mob_spawner() -> RoomOpenedSpawner:
	return mob_spawner as RoomOpenedSpawner


## Spawns Outrun
func spawn() -> void:
	var outrun: Outrun = outrunScene.instantiate()
	Game.room_generator.last_room_opened.add_sibling(outrun)
	outrun.setup(Game.nodeMonsters.get_node_monster_path())
	Game.print_info("Outrun spawned")
	register_active()
