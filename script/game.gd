extends Node

var player: Player
var roomList: RoomList = RoomList.new()
var roomGenerator: RoomGenerator = RoomGenerator.new()

var theWatcher := TheWatcher.new()
var theShade := TheShadeManager.new()
var outrun := OutrunManager.new()

func _ready() -> void:
	roomList.load_rooms()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		get_window().mode = Window.MODE_FULLSCREEN if get_window().mode != Window.MODE_FULLSCREEN else Window.MODE_MAXIMIZED
