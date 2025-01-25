extends Node3D
class_name RoomElement

var room: Room

func _ready() -> void:
	var parent: Node = get_parent()
	while parent is not Room && parent != null:
		parent = parent.get_parent()
	if parent == null:
		printerr("Room element is not a child of a room")
	room = parent
