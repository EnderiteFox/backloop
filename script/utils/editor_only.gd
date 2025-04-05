extends Node

func _ready() -> void:
	if not Engine.is_editor_hint():
		self.queue_free()
