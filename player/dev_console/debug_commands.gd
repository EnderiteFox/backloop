class_name DebugCommands
extends Node

@export var dev_console: DevConsole


func spawn(monster: String) -> void:
	match monster:
		"outrun":
			Game.outrun.spawn()
			dev_console.print_console("Spawned Outrun")
		_:
			dev_console.print_error_console("Unknown monster: %s" % monster)
