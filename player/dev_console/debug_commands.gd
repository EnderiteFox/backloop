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
			
		
func _spawn_the_shade(room: Room) -> void:
	if Game.the_shade.spawn(room):
		dev_console.print_console("The Shade spawned")
	else:
		dev_console.print_error_console("Failed to spawn The Shade")
		
			
func spawn_the_shade(_the_shade: String, where: String) -> void:
	if Game.roomGenerator.rooms.is_empty():
		dev_console.print_error_console("No room to spawn The Shade in")
		return
		
	match where:
		"random":
			_spawn_the_shade(Game.roomGenerator.rooms.pick_random())
		"last":
			_spawn_the_shade(Game.roomGenerator.rooms[-1])
		_:
			dev_console.print_error_console("Invalid location: %s" % where)
	
	
func give(item: String) -> void:
	match item:
		"battery":
			Game.player.inventory.add_consumable(Consumable.Type.BATTERY)
			dev_console.print_console("Gave one battery")
		_:
			dev_console.print_error_console("Unknown item: %s" % item)
