class_name Clock
extends Node3D

var displayed_time: int = 0

func _ready() -> void:
	update_time(Game.time, false)
	Game.time_changed.connect(update_time)


func update_time(new_time: int, _animate: bool = true) -> void:
	displayed_time = new_time
