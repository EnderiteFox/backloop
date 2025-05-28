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
	
	
func give(item: String) -> void:
	match item:
		"battery":
			Game.player.inventory.add_consumable(Consumable.Type.BATTERY)
			dev_console.print_console("Gave one battery")
		_:
			dev_console.print_error_console("Unknown item: %s" % item)
