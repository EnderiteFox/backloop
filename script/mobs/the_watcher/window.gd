extends RoomElement

@onready var watcherSpawnPos: Vector3 = %TheWatcherInsideSpawn.global_position
@onready var watcherLight: Light3D = %TheWatcherViewLight
@onready var watcherRaycast: TheWatcherRaycast = %TheWatcherRaycast
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer2
@onready var watcherTimer: Timer = %TheWatcherTimer

func _ready() -> void:
	super._ready()
	watcherRaycast.saw_player.connect(_on_watcher_see_player)
	room.room_opened.connect(_watcher_spawn)
	watcherTimer.wait_time = Game.theWatcher.ACTIVE_DURATION

func _on_room_opened() -> void:
	if Game.theWatcher.isActive:
		return
	if randf() > Game.theWatcher.SPAWN_CHANCE:
		return
	_watcher_spawn()
	

func _watcher_spawn() -> void:
	watcherRaycast.enabled = true
	watcherLight.visible = true
	Game.theWatcher.isActive = true

func _on_watcher_see_player():
	animationPlayer.play("open")
	%EnterSound.play()
