extends Node3D

func _ready() -> void:
	Game.roomGenerator.fully_generate.call_deferred(%Start)
