extends Node3D

@onready var start_room: Room = %Start

func _ready() -> void:
	Game.room_generator.fully_generate.call_deferred(start_room)
	Game.room_generator.last_room_opened = start_room
	start_room.room_opened.emit()
	start_room.fully_opened.emit()
