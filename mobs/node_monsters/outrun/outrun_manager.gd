class_name OutrunManager
extends Resettable

const SPAWN_CHANCE: float = 0.01

var isActive: bool = false

var outrunScene: PackedScene = preload("res://mobs/node_monsters/outrun/outrun.tscn")


func _init() -> void:
	super._init()
	Game.room_opened.connect(_on_room_opened)


func _on_room_opened(_room: Room) -> void:
	if isActive || !Game.player.is_alive:
		return
	if randf() < SPAWN_CHANCE:
		spawn()


func reset() -> void:
	super.reset()
	isActive = false


## Spawns Outrun
func spawn() -> void:
	var outrun: Outrun = outrunScene.instantiate()
	Game.roomGenerator.lastRoomOpened.add_sibling(outrun)
	outrun.setup(Game.nodeMonsters.get_node_monster_path())
	Game.player.dev_console.print_info_console("Outrun spawned")

