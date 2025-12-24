class_name LootTable
extends Resource


@export var table: Dictionary[LootTableEntry, float]


## Returns a random item based on this loot table
## Returns an empty array if no item was selected
## Returns an array containing the selected item if the element is an item
## Returns an array containing the selected consumable and its amount if the element is a consumable
func poll() -> Array:
	if table.is_empty():
		Game.print_warning("Loot table is empty")
		return []
		
	var sum: float = table.values().reduce(func(acc, val): return acc + val, 0)
	var keys: Array[LootTableEntry] = table.keys()
	var selected: float = randf_range(0.0, sum)
	var current: float = 0.0
	var selected_entry: LootTableEntry = null
	
	for key: LootTableEntry in keys:
		current += table[key]
		if selected <= current:
			selected_entry = key
			break
			
	if selected_entry == null:
		return []
		
	return selected_entry.get_item()
