extends Resettable
class_name OutrunManager

const SPAWN_CHANCE: float = 0.01

var isActive: bool = false

var outrunScene: PackedScene = preload("res://scene/mobs/node_monsters/outrun/outrun.tscn")


## Initializes the manager. Called by Game
func _init() -> void:
	super._init()
	Game.room_opened.connect(_on_room_opened)

func reset() -> void:
	isActive = false

func _on_room_opened(_room: Room) -> void:
	if isActive || !Game.player.is_alive:
		return
	if randf() < SPAWN_CHANCE:
		spawn()


## Spawns Outrun
func spawn() -> void:
	var outrun: Outrun = outrunScene.instantiate()
	Game.roomGenerator.lastRoomOpened.add_sibling(outrun)
	outrun.setup(Game.nodeMonsters.get_node_monster_path())

