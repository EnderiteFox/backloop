extends Node

var player: Player
var roomList: RoomList = RoomList.new()
var roomGenerator: RoomGenerator = RoomGenerator.new()

var theWatcher: TheWatcher = TheWatcher.new()

func _ready() -> void:
	roomList.load_rooms()
