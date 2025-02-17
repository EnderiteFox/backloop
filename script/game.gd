extends Node

const START_TIME: int = 6 * 60

const MIN_TIME_PROGRESS: int = 30
const MAX_TIME_PROGRESS: int = 60

var player: Player

# Room handlers
var roomList := RoomList.new()
@onready var roomGenerator := RoomGenerator.new()

# Monster managers
var theWatcher := TheWatcherManager.new()
var theShade := TheShadeManager.new()
@onready var outrun := OutrunManager.new()

var nodeMonsters := NodeMonsterManager.new()

var _internal_time: int = START_TIME

## The current in-game time. Starts at START_TIME, and generally progresses when doors are open
var time: int:
	get:
		return _internal_time
	set(new_time):
		_internal_time = new_time % (24*60)
		time_changed.emit(new_time)

@warning_ignore("unused_signal")
signal room_opened(room: Room)

@warning_ignore("unused_signal")
signal lights_flicker(duration: float)

signal time_changed(new_time: int)

func _ready() -> void:
	time = START_TIME
	roomList.load_rooms()
	room_opened.connect(_on_room_opened)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		match(get_window().mode):
			Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_MAXIMIZED
			_:
				get_window().mode = Window.MODE_FULLSCREEN

	if event.is_action_pressed("debug"):
		lights_flicker.emit(10)

func _on_room_opened(_room: Room) -> void:
	time += randi_range(MIN_TIME_PROGRESS, MAX_TIME_PROGRESS)

func reset() -> void:
	Resettable.reset_object(self)
	_internal_time = START_TIME
