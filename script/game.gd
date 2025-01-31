extends Node

var player: Player
var roomList: RoomList = RoomList.new()
var roomGenerator: RoomGenerator = RoomGenerator.new()

var theWatcher := TheWatcherManager.new()
var theShade := TheShadeManager.new()
var outrun := OutrunManager.new()

@warning_ignore("unused_signal")
signal room_opened(room: Room)

func _ready() -> void:
	roomList.load_rooms()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		match(get_window().mode):
			Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_MAXIMIZED
			_:
				get_window().mode = Window.MODE_FULLSCREEN
