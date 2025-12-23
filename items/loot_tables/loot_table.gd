class_name LootTable
extends Resource


@export var table: Dictionary[BaseItemInfo, float]


## Returns a random item based on this loot table
## Returns null if no item was selected
func poll() -> BaseItemInfo:
	if table.is_empty():
		Game.print_warning("Loot table is empty")
		return null
		
	var sum: float = table.values().reduce(func(acc, val): return acc + val, 0)
	var keys: Array[BaseItemInfo] = table.keys()
	var selected: float = randf_range(0.0, sum)
	var current: float = 0.0
	
	for key: BaseItemInfo in keys:
		current += table[key]
		if selected <= current:
			return key
			
	return keys[-1]
