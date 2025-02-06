extends Node
class_name Clock

@onready var displayed_time: int = Game.time

func _ready() -> void:
	update_time(Game.time, false)
	Game.time_changed.connect(update_time)

@warning_ignore("unused_parameter")
func update_time(new_time: int, animate: bool = true) -> void:
	displayed_time = new_time
