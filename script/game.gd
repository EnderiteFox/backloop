extends Node

var player: Player
var roomList: RoomList = RoomList.new()

func _ready() -> void:
	roomList.load_rooms()
