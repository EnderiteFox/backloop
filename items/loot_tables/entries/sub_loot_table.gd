class_name SubLootTable
extends LootTableEntry


@export var loot_table: LootTable


func get_item() -> Array:
	return loot_table.poll()
