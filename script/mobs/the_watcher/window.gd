extends RoomElement

@onready var watcherSpawnPos: Vector3 = %TheWatcherInsideSpawn.global_position
@onready var watcherRaycast: TheWatcherRaycast = %TheWatcherRaycast
@onready var animationPlayer: AnimationPlayer = %AnimationPlayer2
@onready var watcherTimer: Timer = %TheWatcherActiveTimer
@onready var watcherModel: TheWatcherModel = %TheWatcherModel

@export var watcherSpawnSounds: Array[AudioStream]

func _ready() -> void:
	super._ready()
	watcherRaycast.saw_player.connect(_on_watcher_see_player)
	room.room_opened.connect(_on_room_opened)
	watcherTimer.timeout.connect(_watcher_deactivate)
	watcherModel.visible = false

func _on_room_opened() -> void:
	if Game.theWatcher.isActive:
		return
	if randf() <= Game.theWatcher.SPAWN_CHANCE:
		_watcher_activate()
	
func _watcher_activate() -> void:
	Game.theWatcher.isActive = true
	get_tree().create_timer(
		randf_range(
			Game.theWatcher.MIN_SPAWN_DELAY,
			Game.theWatcher.MAX_SPAWN_DELAY
		)
	).timeout.connect(_watcher_warn)
	
func _watcher_warn() -> void:
	watcherModel.visible = true
	watcherModel.animationPlayer.play("peek")
	%SpawnSound.stream = watcherSpawnSounds.pick_random()
	%SpawnSound.play()
	get_tree().create_timer(Game.theWatcher.REACT_TIME).timeout.connect(_watcher_spawn)

func _watcher_spawn() -> void:
	watcherRaycast.enabled = true
	Game.theWatcher.isActive = true
	watcherTimer.start(Game.theWatcher.ACTIVE_DURATION)

func _watcher_deactivate() -> void:
	watcherRaycast.enabled = false
	Game.theWatcher.isActive = false
	%SpawnSound.stream = watcherSpawnSounds.pick_random()
	%SpawnSound.play()

func _on_watcher_see_player():
	watcherTimer.stop()
	animationPlayer.play("open")
	%EnterSound.play()
